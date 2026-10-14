{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    wezterm = lib.getExe self'.packages.wezterm;
    helix = lib.getExe self'.packages.helix;
    yazi = lib.getExe self'.packages.yazi;

    # space previews through sushi, nemo-preview is x11 only
    nemo = pkgs.nemo.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace src/nemo-previewer.c \
            --replace-fail '#define PREVIEWER_DBUS_NAME "org.nemo.Preview"' '#define PREVIEWER_DBUS_NAME "org.gnome.NautilusPreviewer"' \
            --replace-fail '#define PREVIEWER_DBUS_IFACE "org.nemo.Preview"' '#define PREVIEWER_DBUS_IFACE "org.gnome.NautilusPreviewer2"' \
            --replace-fail '"/org/nemo/Preview"' '"/org/gnome/NautilusPreviewer"' \
            --replace-fail '"(sib)"' '"(ssbs)"' \
            --replace-fail 'uri, xid, close_if_already_visible' 'uri, "", close_if_already_visible, ""'
        '';
    });

    # upstream builds its nemo flavour the same way
    folder-color = pkgs.stdenvNoCC.mkDerivation {
      pname = "folder-color-nemo";
      version = "0-unstable-2026-04-12";
      src = pkgs.fetchFromGitHub {
        owner = "costales";
        repo = "folder-color";
        rev = "af8dd5323c253740a0bc0a9ffea0af9e675f73ef";
        hash = "sha256-0dXcp7/Js6Hk/QfbqLXRnZ8wdbA542e6gj08TqPez34=";
      };
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        install -d $out/share/nemo-python/extensions
        substitute extension/folder-color.py $out/share/nemo-python/extensions/folder-color.py \
          --replace-fail Nautilus Nemo
        runHook postInstall
      '';
    };

    nemo-with-extensions = pkgs.nemo-with-extensions.override {
      inherit nemo;
      useDefaultExtensions = false;
      extensions = [
        pkgs.nemo-python
        # compress and extract
        pkgs.nemo-fileroller
        folder-color
      ];
    };

    # Custom actions
    action = id: fields:
      pkgs.writeTextDir "share/nemo/actions/${id}.nemo_action" (lib.generators.toINI {} {"Nemo Action" = fields;});

    # also on the background menu, for the current folder
    withHere = id: fields: {
      ${id} = fields;
      "${id}-here" =
        fields
        // {
          Selection = "none";
          Extensions = "any;";
        };
    };

    actions = lib.mapAttrsToList action (
      {
        helix = {
          Name = "Open in Helix";
          Icon-Name = "helix";
          Exec = "${wezterm} start --cwd %P -- ${helix} %F";
          Selection = "notnone";
          Extensions = "nodirs;";
        };
        zed = {
          Name = "Open in Zed";
          Icon-Name = "zed";
          Exec = "zeditor %F";
          Selection = "any";
          Extensions = "any;";
          Dependencies = "zeditor;";
        };
        helix-root = {
          Name = "Edit as root";
          Icon-Name = "dialog-password";
          Exec = "${wezterm} start --cwd %P -- sudo ${helix} %F";
          Selection = "notnone";
          Extensions = "nodirs;";
        };
        kdeconnect = {
          Name = "Send to phone";
          Icon-Name = "kdeconnect";
          Exec = "kdeconnect-handler %F";
          Selection = "s";
          Extensions = "nodirs;";
          Dependencies = "kdeconnect-handler;";
        };
        collision = {
          Name = "Check hashes";
          Icon-Name = "dev.geopjr.Collision";
          Exec = "${lib.getExe pkgs.collision} %F";
          Selection = "s";
          Extensions = "nodirs;";
        };
        wallpaper = {
          Name = "Set as wallpaper";
          Icon-Name = "preferences-desktop-wallpaper";
          Exec = "dms ipc call wallpaper set %F";
          Selection = "s";
          Mimetypes = "image/*;";
          Dependencies = "dms;";
        };
      }
      // withHere "helix-folder" {
        Name = "Open in Helix";
        Icon-Name = "helix";
        Exec = "${wezterm} start --cwd %F -- ${helix} .";
        Selection = "s";
        Extensions = "dir;";
      }
      // withHere "yazi" {
        Name = "Open yazi here";
        Icon-Name = "system-file-manager";
        Exec = "${wezterm} start -- ${yazi} %F";
        Selection = "s";
        Extensions = "any;";
      }
    );

    data = pkgs.buildEnv {
      name = "nemo-data";
      paths =
        actions
        ++ [
          # Thumbnailers
          pkgs.gst-thumbnailers
          pkgs.glycin-thumbnailer
          pkgs.papers
          pkgs.f3d
        ];
      pathsToLink = [
        "/share/nemo/actions"
        "/share/thumbnailers"
      ];
    };
  in {
    packages.nemo = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = nemo-with-extensions;
      }
      {
        # D-Bus activation must start the wrapper too
        filesToPatch = [
          "share/applications/*.desktop"
          "share/dbus-1/services/*.service"
        ];

        prefixVar = [["XDG_DATA_DIRS" ":" "${data}/share"]];
        # pdf content search
        suffixVar = [["PATH" ":" (lib.makeBinPath [pkgs.poppler-utils])]];
      }
    ];
  };
}

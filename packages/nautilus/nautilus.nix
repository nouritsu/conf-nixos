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

    # nautilus-python scripts, copied as-is
    mkExtension = {install, ...} @ args:
      pkgs.stdenvNoCC.mkDerivation (removeAttrs args ["install"]
        // {
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            dir=$out/share/nautilus-python/extensions
            ${install}
            runHook postInstall
          '';
        });

    copy-path = mkExtension rec {
      pname = "nautilus-copy-path";
      version = "1.10.3";
      src = pkgs.fetchFromGitHub {
        owner = "chr314";
        repo = "nautilus-copy-path";
        tag = version;
        hash = "sha256-DvBwqko45tcjfoBWpuas8pLGmkw2Gibwt5BtrN7gF0k=";
      };
      install = ''
        install -Dm644 nautilus-copy-path.py -t $dir
        install -Dm644 nautilus_copy_path.py translation.py config.json -t $dir/nautilus-copy-path
        cp -r translations $dir/nautilus-copy-path
      '';
      passthru.nup = [];
    };

    media-columns = mkExtension rec {
      pname = "nautilus-media-columns";
      version = "1.1.2";
      src = pkgs.fetchFromGitHub {
        owner = "derek-shnosh";
        repo = "nautilus-media-columns";
        tag = "v${version}";
        hash = "sha256-M3J7nM4f8F5KxPJxBA0/yC6FizyPKy6Ek6fTRJsnyWk=";
      };
      install = "install -Dm644 nautilus-media-columns.py -t $dir";
      passthru.nup = [];
    };

    folder-color = mkExtension {
      pname = "folder-color";
      version = "0-unstable-2026-04-12";
      src = pkgs.fetchFromGitHub {
        owner = "costales";
        repo = "folder-color";
        rev = "af8dd5323c253740a0bc0a9ffea0af9e675f73ef";
        hash = "sha256-0dXcp7/Js6Hk/QfbqLXRnZ8wdbA542e6gj08TqPez34=";
      };
      install = "install -Dm644 extension/folder-color.py -t $dir";
      passthru.nup = ["--version=branch"];
    };

    # nautilus quits with its last window otherwise
    keep-alive = pkgs.writeTextDir "share/nautilus-python/extensions/keep-alive.py" ''
      from gi.repository import Gio

      Gio.Application.get_default().hold()
    '';

    # v2 interpolation quotes paths with spaces
    command = action:
      {
        type = "command";
        use_v1_interpolation = false;
      }
      // action;

    actions = (pkgs.formats.json {}).generate "actions-for-nautilus.json" {
      sort = "manual";
      actions = map command [
        {
          label = "Open in Helix";
          command_line = "${wezterm} start --cwd %d -- ${helix} %F";
          filetypes = ["file"];
        }
        {
          label = "Open in Helix";
          command_line = "${wezterm} start --cwd %f -- ${helix} .";
          filetypes = ["directory"];
          max_items = 1;
        }
        {
          label = "Open yazi here";
          command_line = "${wezterm} start -- ${yazi} %f";
          max_items = 1;
        }
        {
          label = "Edit as root";
          command_line = "${wezterm} start --cwd %d -- sudo ${helix} %F";
          filetypes = ["file"];
        }
      ];
    };

    actions-for-nautilus = mkExtension rec {
      pname = "actions-for-nautilus";
      version = "2.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "bassmanitram";
        repo = "actions-for-nautilus";
        tag = "v${version}";
        hash = "sha256-GUJtB4qi9T6f7oqPjyF/0YftPeLfZyZ2Xb2IVc7tWdU=";
      };
      postPatch = ''
        substituteInPlace extensions/actions-for-nautilus/afn_config.py \
          --replace-fail 'HOME + "/.local/share/actions-for-nautilus/config.json"' '"${actions}"'
      '';
      install = ''
        install -Dm644 extensions/actions-for-nautilus.py -t $dir
        install -Dm644 extensions/actions-for-nautilus/*.py -t $dir/actions-for-nautilus
      '';
      passthru.nup = [];
    };

    extensions = pkgs.buildEnv {
      name = "nautilus-extensions";
      paths = [
        # NAUTILUS_4_EXTENSION_DIR replaces nautilus's own dir
        pkgs.nautilus
        pkgs.nautilus-python

        pkgs.wezterm
        pkgs.nautilus-open-any-terminal
        self'.packages.kdeconnect
        pkgs.collision
        pkgs.turtle
        copy-path
        actions-for-nautilus
        media-columns
        folder-color
        keep-alive

        # Thumbnailers
        pkgs.gst-thumbnailers
        pkgs.glycin-thumbnailer
        pkgs.papers
      ];
      pathsToLink = [
        "/lib/nautilus/extensions-4"
        "/share/nautilus-python/extensions"
        "/share/thumbnailers"
      ];
    };
  in {
    # flake outputs so nup can bump them
    packages.nautilus-copy-path = copy-path;
    packages.nautilus-media-columns = media-columns;
    packages.nautilus-folder-color = folder-color;
    packages.actions-for-nautilus = actions-for-nautilus;

    packages.nautilus = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.nautilus;
      }
      {
        # nautilus is D-Bus activated, so its services must start the wrapper too
        filesToPatch = [
          "share/applications/*.desktop"
          "share/dbus-1/services/*.service"
        ];

        env.NAUTILUS_4_EXTENSION_DIR = "${extensions}/lib/nautilus/extensions-4";

        prefixVar = [
          ["XDG_DATA_DIRS" ":" "${extensions}/share"]
          # turtle's extension reads its settings in-process
          ["XDG_DATA_DIRS" ":" (pkgs.glib.getSchemaDataDirPath pkgs.turtle)]
          # demuxers for media columns and the audio/video properties page
          [
            "GST_PLUGIN_SYSTEM_PATH_1_0"
            ":"
            (lib.makeSearchPath "lib/gstreamer-1.0" [
              pkgs.gst_all_1.gst-plugins-good
              pkgs.gst_all_1.gst-plugins-bad
            ])
          ]
        ];
      }
    ];
  };
}

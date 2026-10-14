{lib, ...}: {
  den.aspects.nemo = {host, ...}: let
    primary = lib.head (lib.attrNames host.users);
  in {
    nixos = {
      self',
      pkgs,
      config,
      ...
    }: let
      home = config.users.users.${primary}.home;
      nemo = self'.packages.nemo;

      # also the sidebar's bookmarks
      bookmarks = pkgs.writeText "bookmarks" (lib.concatMapStrings (dir: "file://${home}/${dir}\n") [
        "Documents"
        "Downloads"
        "Pictures"
        "Music"
        "Videos"
        "Projects"
        ".config/nixos"
      ]);

      # nemo starts the terminal inside the folder, without passing it
      terminal = pkgs.writeShellScript "nemo-terminal" ''
        exec ${lib.getExe self'.packages.wezterm} start --cwd "$PWD" "$@"
      '';
    in {
      environment.systemPackages = [nemo];
      services.dbus.packages = [nemo];

      # warm instance, so windows open instantly
      systemd.user.services.nemo = {
        description = "Nemo file manager";
        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target"];
        environment.NEMO_PERSIST = "1";
        # apps opened from nemo need the session PATH
        enableDefaultPath = false;
        serviceConfig = {
          Type = "dbus";
          BusName = "org.Nemo";
          ExecStart = "${lib.getExe nemo} --no-default-window";
        };
      };

      # trash, phones, network shares, removable drives
      services.gvfs.enable = true;

      # space to preview
      services.gnome.sushi.enable = true;

      xdg.mime.defaultApplications."inode/directory" = "nemo.desktop";

      programs.dconf.profiles.user.databases = [
        {
          lockAll = true;
          settings =
            {
              "org/nemo/preferences" = {
                default-folder-viewer = "list-view";
                show-open-in-terminal-toolbar = true;
                show-toggle-extra-pane-toolbar = true;
              };
              # Edit as root action instead
              "org/nemo/preferences/menu-config" = {
                selection-menu-open-as-root = false;
                background-menu-open-as-root = false;
              };
              "org/nemo/list-view" = {
                default-visible-columns = ["name" "size" "date_modified"];
                enable-folder-expansion = true;
              };
              "org/cinnamon/desktop/applications/terminal".exec = "${terminal}";
            }
            // lib.genAttrs ["org/gtk/settings/file-chooser" "org/gtk/gtk4/settings/file-chooser"] (_: {
              show-hidden = true;
              sort-directories-first = true;
            });
        }
        # left writable so toggles stick
        {
          settings = {
            "org/nemo/preferences".show-hidden-files = true;
            "org/nemo/window-state".start-with-menu-bar = false;
          };
        }
      ];

      systemd.user.tmpfiles.rules = ["L+ %h/.config/gtk-3.0/bookmarks - - - - ${bookmarks}"];
    };
  };
}

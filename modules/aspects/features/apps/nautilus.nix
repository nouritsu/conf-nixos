{lib, ...}: {
  den.aspects.nautilus = {host, ...}: let
    primary = lib.head (lib.attrNames host.users);
  in {
    nixos = {
      self',
      pkgs,
      config,
      ...
    }: let
      home = config.users.users.${primary}.home;

      # also the sidebar's only folder list
      bookmarks = pkgs.writeText "bookmarks" (lib.concatMapStrings (dir: "file://${home}/${dir}\n") [
        "Documents"
        "Downloads"
        "Pictures"
        "Music"
        "Videos"
        "Projects"
        ".config/nixos"
      ]);
    in {
      environment.systemPackages = [
        self'.packages.nautilus

        # their menu entries run these from PATH; turtle's emblems need its D-Bus service
        pkgs.collision
        pkgs.turtle
      ];

      # warm instance, so windows open instantly
      systemd.user.services.nautilus = {
        description = "Nautilus file manager";
        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target"];
        # apps opened from nautilus need the session PATH
        enableDefaultPath = false;
        serviceConfig = {
          Type = "dbus";
          BusName = "org.gnome.Nautilus";
          ExecStart = "${lib.getExe self'.packages.nautilus} --gapplication-service";
        };
      };

      # trash, phones, network shares, removable drives
      services.gvfs.enable = true;

      # space to preview
      services.gnome.sushi.enable = true;

      # full text search
      services.gnome.localsearch.enable = true;
      services.gnome.tinysparql.enable = true;
      # the indexer unit is conditioned on it, and the niri session never exports it
      systemd.user.settings.Manager.DefaultEnvironment = "XDG_SESSION_CLASS=user";

      xdg.mime.defaultApplications = lib.genAttrs [
        "inode/directory"
        "x-scheme-handler/file"
        "x-scheme-handler/sftp"
      ] (_: "org.gnome.Nautilus.desktop");

      programs.dconf.profiles.user.databases = [
        {
          lockAll = true;
          settings = {
            "org/gnome/nautilus/preferences".default-folder-viewer = "list-view";
            "org/gnome/nautilus/list-view" = {
              default-visible-columns = ["name" "size" "date_modified"];
              use-tree-view = true;
            };

            # shared with the GTK 4 file chooser
            "org/gtk/gtk4/settings/file-chooser" = {
              show-hidden = true;
              sort-directories-first = true;
            };

            "com/github/stunkymonkey/nautilus-open-any-terminal".terminal = "wezterm";

            # glib has no &PROJECTS yet
            "org/freedesktop/tracker/miner/files".index-recursive-directories = [
              "&DESKTOP"
              "&DOCUMENTS"
              "&DOWNLOAD"
              "&MUSIC"
              "&PICTURES"
              "&VIDEOS"
              "$HOME/Projects"
            ];
          };
        }
      ];

      systemd.user.tmpfiles.rules = ["L+ %h/.config/gtk-3.0/bookmarks - - - - ${bookmarks}"];
    };
  };
}

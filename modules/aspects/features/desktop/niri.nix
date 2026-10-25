{
  den.aspects.niri = {
    nixos = {
      self',
      inputs',
      pkgs,
      lib,
      config,
      ...
    }: let
      wniri = self'.packages.niri;
    in {
      programs.niri = {
        enable = true;
        package = wniri;
      };

      # graphical-desktop turns it on; 700 MB of voices nothing here uses
      services.speechd.enable = false;

      environment.systemPackages = [inputs'.niri-cwd.packages.niri-cwd];

      which-key'.menu.t.submenu.z = {
        desc = "woomer";
        icon = "f034b";
        cmd = lib.getExe pkgs.woomer;
      };

      systemd.user.tmpfiles.rules = [
        # for tools that look in ~/.config/niri (DMS, niri validate)
        "L+ %h/.config/niri/config.kdl - - - - ${wniri}/niri-config.kdl"
        # repo mime defaults win over the mimeapps.list apps write to
        "L+ %h/.config/niri-mimeapps.list - - - - /etc/xdg/mimeapps.list"
      ];

      # restart niri with new settings on rebuild
      system.userActivationScripts.niri-reload-config = {
        text = lib.getExe (
          pkgs.writeShellApplication {
            name = "niri-reload-config";
            runtimeInputs = [
              config.programs.niri.package
              pkgs.procps
            ];
            text = ''
              if pgrep -x "niri" > /dev/null; then
                niri msg action load-config-file --path "${wniri}/niri-config.kdl"
              fi
            '';
          }
        );
      };
    };

    provides.portals.nixos = {
      self',
      pkgs,
      ...
    }: let
      niri = self'.packages.niri;
    in {
      xdg.portal = {
        enable = true;
        configPackages = [niri];

        # handlers start in the session env, not inside steam's or a wrapper's
        xdgOpenUsePortal = true;

        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];

        config = {
          common.default = ["gtk"];
          niri.default = ["gnome" "gtk"];
        };
      };
    };

    provides.xwayland.nixos = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = [pkgs.xwayland-satellite];
      services.xserver.enable = lib.mkForce false;

      # defaults to xserver.enable; without caches gtk scans every icon on launch
      gtk.iconCache.enable = true;
    };
  };
}

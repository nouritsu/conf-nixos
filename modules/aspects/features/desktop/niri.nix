{
  den.aspects.niri = {
    nixos = {
      self',
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

      environment.variables.XDG_SESSION_TYPE = "wayland";

      services.xserver.enable = lib.mkDefault true;
      services.xserver.excludePackages = [pkgs.xterm];

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
    };
  };
}

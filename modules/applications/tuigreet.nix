{self, ...}: {
  flake.nixosModules.app-tuigreet = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    tuigreet = lib.getExe pkgs.tuigreet;
    niri = self.packages.${system}.niri;
    sessions = "/run/current-system/sw/share/wayland-sessions";
  in {
    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = "${niri}/bin/niri";
      };
    };
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session --sessions ${sessions}";
          user = "greeter";
        };
      };
    };
  };
}

{self, ...}: {
  flake.nixosModules.app-tuigreet = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    tuigreet = lib.getExe pkgs.tuigreet;
    niri = self.packages.${system}.niri;
    sessions = "${niri}/share/wayland-sessions";
  in {
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

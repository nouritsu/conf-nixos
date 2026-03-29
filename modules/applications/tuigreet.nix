{self, ...}: {
  flake.nixosModules.app-tuigreet = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    tuigreet = lib.getExe pkgs.tuigreet;
    niri-sessions = "${self.packages.${system}.niri}/share/wayland-sessions";
  in {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session --sessions ${niri-sessions}";
          user = "greeter";
        };
      };
    };
  };
}

{
  den.aspects.greeter.nixos = {
    self',
    pkgs,
    lib,
    ...
  }: let
    tuigreet = lib.getExe pkgs.tuigreet;
    niri = self'.packages.niri;
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

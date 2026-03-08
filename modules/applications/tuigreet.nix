{inputs, ...}: {
  flake.nixosModules.app-tuigreet = {
    pkgs,
    config,
    lib,
    ...
  }: let
    tuigreet = lib.getExe pkgs.tuigreet;
    hyprland-sessions = "${inputs.hyprland.packages.${config.my.system.arch}.hyprland}/share/wayland-sessions";
  in {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-sessions}";
          user = "greeter";
        };
      };
    };
  };
}

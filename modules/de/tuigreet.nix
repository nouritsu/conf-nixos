{
  inputs,
  pkgs,
  config,
  ...
}: let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
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
}

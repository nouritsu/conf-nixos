{
  inputs,
  pkgs,
  usrconf,
  ...
}: let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  hyprland-sessions = "${inputs.hyprland.packages.${usrconf.system}.hyprland}/share/wayland-sessions";
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-sessions}";
        user = "${usrconf.user.alias}";
      };
    };
  };
}

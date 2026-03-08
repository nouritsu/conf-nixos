{
  flake.nixosModules.app-woomer = {pkgs, ...}: {
    my.hmModules = ["app-woomer"];

    environment.systemPackages = [
      pkgs.woomer
    ];
  };

  flake.homeModules.app-woomer = {...}: {
    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, Z, exec, woomer"
    ];

    wayland.windowManager.hyprland.settings.windowrule = let
      m = "match:title woomer";
    in [
      "no_anim on, ${m}"
      "immediate on, ${m}"
    ];
  };
}

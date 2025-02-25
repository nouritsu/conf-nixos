{
  inputs,
  pkgs,
  ...
}: let
  terminal = "${pkgs.foot}/bin/footclient";
  browser = "${pkgs.google-chrome}/bin/google-chrome-stable --ozone-platform=wayland";
  explorer = "${pkgs.nemo-with-extensions}/bin/nemo";
  menu = "${pkgs.tofi}/bin/tofi-drun --drun-launch=true";
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    settings = {
      bind =
        [
          "SUPER, T, exec, ${terminal}"
          "SUPER, RETURN, exec, ${terminal}"
          "SUPER, W, exec, ${browser}"
          "SUPER, E, exec, ${explorer}"
          "SUPER, SUPER_L, exec, ${menu}"
        ]
        ++ [
          "SUPER, H, movefocus, l"
          "SUPER, J, movefocus, d"
          "SUPER, K, movefocus, u"
          "SUPER, L, movefocus, r"
          "SUPER, left, movefocus, l"
          "SUPER, down, movefocus, d"
          "SUPER, up, movefocus, u"
          "SUPER, right, movefocus, r"

          "SUPER, Q, killactive,"
        ];
    };
  };
}

{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  hyprland = inputs.hyprland.packages.${osConfig.my.system.arch}.hyprland;
  hyprctl = lib.getExe' hyprland "hyprctl";
  jq = lib.getExe pkgs.jq;
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";

  copy-active-pid = pkgs.writeShellScript "waybar-copy-active-pid" ''
    # focusHistoryID = 0 => window is in focus
    pid=$(${hyprctl} clients -j | ${jq} -r '.[] | select(.focusHistoryID == 0) | .pid')
    echo -n "$pid" | ${wl-copy}
  '';
in {
  programs.waybar.settings.default."hyprland/window" = {
    format = "{}";
    tooltip = true;
    tooltip-format = "Copy PID";
    rewrite = {
      "" = "desktop";
      "~" = "terminal";
      "fish" = "terminal";
      "(.*) — Mozilla Firefox" = "firefox";
    };
    on-click = "${copy-active-pid}";
    swap-icon-label = false;
    separate-outputs = true;
  };

  my.waybar.styles.parts =
    /*
    css
    */
    ''
      #gwindows #window {
        margin-left: 8px;
      }

      #window label {
        font-weight: normal;
      }
    '';
}

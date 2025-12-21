{
  config,
  pkgs,
  ...
}: let
  fzf = "${pkgs.fzf}/bin/fzf";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  printf = "${pkgs.coreutils}/bin/printf";

  power-menu-script = pkgs.writeShellScriptBin "waybar-power-menu" ''
    RED='\033[1;31m'
    RST='\033[0m'

    wait-for-key() {
      ${printf} '\n%bPress [q] or [ESC] to close%b\n' "$RED" "$RST"
      while true; do
        read -rsn1 key
        if [[ $key == 'q' || $key == 'Q' || $key == $'\e' ]]; then
          break
        fi
      done
    }

    main() {
      local list=(
        'Lock'
        'Shutdown'
        'Reboot'
      )
      local opts=(
        '--border=sharp'
        '--border-label= Power Menu '
        '--height=~100%'
        '--highlight-line'
        '--no-input'
        '--pointer='
        '--reverse'
      )

      local selected
      selected=$(${printf} '%s\n' "''${list[@]}" | ${fzf} "''${opts[@]}")
      case $selected in
        'Lock') ${hyprctl} dispatch exec hyprlock ;;
        'Shutdown') ${systemctl} poweroff ;;
        'Reboot') ${systemctl} reboot ;;
        *) exit 0 ;;
      esac
    }

    main
  '';
in {
  programs.waybar.settings.default."custom/power_menu" = {
    format = "󰤄";
    on-click = "${config.programs.wezterm.package}/bin/wezterm start --class waybar-power-menu -- ${power-menu-script}/bin/waybar-power-menu";
    tooltip-format = "Power Menu";
  };
}

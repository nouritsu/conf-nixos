{config, pkgs, ...}: let
  fzf = "${pkgs.fzf}/bin/fzf";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  printf = "${pkgs.coreutils}/bin/printf";

  power-menu-script = pkgs.writeShellScriptBin "waybar-power-menu" ''
    main() {
      local list=(
        'Lock'
        'Shutdown'
        'Reboot'
        'Logout'
        'Hibernate'
        'Suspend'
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
        'Lock') ${loginctl} lock-session ;;
        'Shutdown') ${systemctl} poweroff ;;
        'Reboot') ${systemctl} reboot ;;
        'Logout') ${loginctl} terminate-session "$XDG_SESSION_ID" ;;
        'Hibernate') ${systemctl} hibernate ;;
        'Suspend') ${systemctl} suspend ;;
        *) exit 1 ;;
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

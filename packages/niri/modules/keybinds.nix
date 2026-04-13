{self, ...}: {
  flake.nixosModules.wniri-keybinds = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    woomer = lib.getExe pkgs.woomer;
    wezterm = lib.getExe self.packages.${system}.wezterm;
    scrcpy = lib.getExe self.packages.${system}.scrcpy;
  in {
    settings.window-rules = [
      {
        matches = [{app-id = "^\\.scrcpy-wrapped$";}];
        default-column-width = {fixed = 615;};
      }
    ];

    settings.binds = {
      # Applications
      "Mod+Return".spawn = wezterm;
      "Mod+W".spawn = "brave";

      "Mod+D".spawn = "vesktop";
      "Mod+Z".spawn = woomer;
      "Mod+P".spawn = scrcpy;

      "Mod+S".spawn = "pavucontrol";
      "Mod+B".spawn = "blueman-manager";
      "Mod+N".spawn = "nm-connection-editor";

      "Mod+A".spawn-sh = "dms ipc call spotlight toggle";
      "Mod+I".spawn-sh = "dms ipc call settings focusOrToggle";
      "Mod+V".spawn-sh = "dms ipc call clipboard toggle";
      "Mod+Escape".spawn-sh = "dms ipc call powermenu toggle";
      "Mod+Alt+W".spawn-sh = "dms ipc call dankdash wallpaper";
      "Mod+Space".spawn-sh = "dms ipc call notifications toggle";

      # Window actions
      "Mod+Q".close-window = {};
      "Mod+C".center-visible-columns = {};
      "Mod+Shift+C".center-window = {};
      "Mod+F".fullscreen-window = {};
      "Mod+Shift+F".toggle-window-floating = {};
      "Mod+R".switch-preset-column-width = {};
      "Mod+M".maximize-column = {};
      "Mod+Shift+M".expand-column-to-available-width = {};
      "Mod+Tab".toggle-overview = {};
      "Mod+WheelScrollDown".focus-column-left = {};
      "Mod+WheelScrollUp".focus-column-right = {};
      "Mod+Shift+WheelScrollDown".focus-workspace-down = {};
      "Mod+Shift+WheelScrollUp".focus-workspace-up = {};

      # Focus column left/right (win_focus lr)
      "Mod+H".focus-column-or-monitor-left = {};
      "Mod+left".focus-column-or-monitor-left = {};
      "Mod+L".focus-column-or-monitor-right = {};
      "Mod+right".focus-column-or-monitor-right = {};

      # Focus window/workspace up/down (win_focus ud)
      "Mod+K".focus-window-or-workspace-up = {};
      "Mod+up".focus-window-or-workspace-up = {};
      "Mod+J".focus-window-or-workspace-down = {};
      "Mod+down".focus-window-or-workspace-down = {};

      # Move column left/right (win_move lr)
      "Mod+Shift+H".move-column-left-or-to-monitor-left = {};
      "Mod+Shift+left".move-column-left-or-to-monitor-left = {};
      "Mod+Shift+L".move-column-right-or-to-monitor-right = {};
      "Mod+Shift+right".move-column-right-or-to-monitor-right = {};

      # Move window to workspace up/down (win_move ud)
      "Mod+Shift+K".move-window-to-workspace-up = {};
      "Mod+Shift+up".move-window-to-workspace-up = {};
      "Mod+Shift+J".move-window-to-workspace-down = {};
      "Mod+Shift+down".move-window-to-workspace-down = {};

      # Focus workspace 1–9 (ws_focus)
      "Mod+1".focus-workspace = 1;
      "Mod+2".focus-workspace = 2;
      "Mod+3".focus-workspace = 3;
      "Mod+4".focus-workspace = 4;
      "Mod+5".focus-workspace = 5;
      "Mod+6".focus-workspace = 6;
      "Mod+7".focus-workspace = 7;
      "Mod+8".focus-workspace = 8;
      "Mod+9".focus-workspace = 9;

      # Move column to workspace 1–9 (ws_move)
      "Mod+Shift+1".move-column-to-workspace = 1;
      "Mod+Shift+2".move-column-to-workspace = 2;
      "Mod+Shift+3".move-column-to-workspace = 3;
      "Mod+Shift+4".move-column-to-workspace = 4;
      "Mod+Shift+5".move-column-to-workspace = 5;
      "Mod+Shift+6".move-column-to-workspace = 6;
      "Mod+Shift+7".move-column-to-workspace = 7;
      "Mod+Shift+8".move-column-to-workspace = 8;
      "Mod+Shift+9".move-column-to-workspace = 9;
    };
  };
}

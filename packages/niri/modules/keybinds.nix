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
    yazi = lib.getExe self.packages.${system}.yazi;
    nautilus = lib.getExe self.packages.${system}.nautilus;
    brave = lib.getExe pkgs.brave;

    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
    brightnessctl = lib.getExe pkgs.brightnessctl;
    playerctl = lib.getExe pkgs.playerctl;
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
      "Mod+W".spawn = brave;
      "Mod+E".spawn = [nautilus "--new-window"];
      "Mod+Shift+E".spawn = [wezterm "start" "--" yazi];

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
      "Mod+Shift+Escape".spawn-sh = "dms ipc call lock lock";
      "Ctrl+Shift+Escape".spawn-sh = "dms ipc call processlist focusOrToggle";
      "Mod+Alt+W".spawn-sh = "dms ipc call dankdash wallpaper";
      "Mod+Shift+W".spawn-sh = "dms ipc call wallpaperCarousel toggle";
      "Mod+C".spawn-sh = "dms color pick -a";
      "Mod+Space".spawn-sh = "dms ipc call notifications toggle";

      # Audio
      "XF86AudioRaiseVolume".spawn = [wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
      "XF86AudioLowerVolume".spawn = [wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
      "XF86AudioMute".spawn = [wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
      "XF86AudioMicMute".spawn = [wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];

      # Brightness
      "XF86MonBrightnessUp".spawn = [brightnessctl "set" "5%+"];
      "XF86MonBrightnessDown".spawn = [brightnessctl "set" "5%-"];

      # Media
      "XF86AudioPlay".spawn = [playerctl "play-pause"];
      "XF86AudioPrev".spawn = [playerctl "previous"];
      "XF86AudioNext".spawn = [playerctl "next"];

      # Screenshot
      "Print".spawn-sh = "dms ipc call screenshotPlus capture";
      "Shift+Print".screenshot-screen = {};
      "Ctrl+Print".screenshot = {};

      # Clipping
      "Mod+G".spawn = ["gsr-ui-cli" "toggle-show"];
      "Mod+Alt+G".spawn = ["gsr-ui-cli" "replay-save"];
      "Mod+Shift+G".spawn = ["gsr-ui-cli" "toggle-replay"];
      "Mod+Alt+R".spawn = ["gsr-ui-cli" "toggle-record"];

      # Window actions
      "Mod+Q".close-window = {};
      "Mod+Ctrl+C".center-visible-columns = {};
      "Mod+Shift+C".center-window = {};
      "Mod+F".fullscreen-window = {};
      "Mod+Shift+F".toggle-window-floating = {};
      "Mod+R".switch-preset-column-width = {};
      "Mod+M".maximize-column = {};
      "Mod+Shift+M".expand-column-to-available-width = {};
      "Mod+Tab".toggle-overview = {};
      "Mod+Shift+V".switch-focus-between-floating-and-tiling = {};
      "Mod+WheelScrollDown".focus-column-left = {};
      "Mod+WheelScrollUp".focus-column-right = {};
      "Mod+Shift+WheelScrollDown".focus-workspace-down = {};
      "Mod+Shift+WheelScrollUp".focus-workspace-up = {};

      # Columns
      "Mod+BracketLeft".consume-or-expel-window-left = {};
      "Mod+BracketRight".consume-or-expel-window-right = {};
      "Mod+Comma".consume-window-into-column = {};
      "Mod+Period".expel-window-from-column = {};
      "Mod+T".toggle-column-tabbed-display = {};
      "Mod+Home".focus-column-first = {};
      "Mod+End".focus-column-last = {};

      # Sizing
      "Mod+Minus".set-column-width = "-10%";
      "Mod+Equal".set-column-width = "+10%";
      "Mod+Shift+Minus".set-window-height = "-10%";
      "Mod+Shift+Equal".set-window-height = "+10%";
      "Mod+Shift+R".switch-preset-window-height = {};
      "Mod+Ctrl+R".reset-window-height = {};

      "Mod+H".focus-column-or-monitor-left = {};
      "Mod+left".focus-column-or-monitor-left = {};
      "Mod+L".focus-column-or-monitor-right = {};
      "Mod+right".focus-column-or-monitor-right = {};

      "Mod+K".focus-window-or-workspace-up = {};
      "Mod+up".focus-window-or-workspace-up = {};
      "Mod+J".focus-window-or-workspace-down = {};
      "Mod+down".focus-window-or-workspace-down = {};

      "Mod+Shift+H".move-column-left-or-to-monitor-left = {};
      "Mod+Shift+left".move-column-left-or-to-monitor-left = {};
      "Mod+Shift+L".move-column-right-or-to-monitor-right = {};
      "Mod+Shift+right".move-column-right-or-to-monitor-right = {};

      "Mod+Shift+K".move-window-to-workspace-up = {};
      "Mod+Shift+up".move-window-to-workspace-up = {};
      "Mod+Shift+J".move-window-to-workspace-down = {};
      "Mod+Shift+down".move-window-to-workspace-down = {};

      "Mod+1".focus-workspace = 1;
      "Mod+2".focus-workspace = 2;
      "Mod+3".focus-workspace = 3;
      "Mod+4".focus-workspace = 4;
      "Mod+5".focus-workspace = 5;
      "Mod+6".focus-workspace = 6;
      "Mod+7".focus-workspace = 7;
      "Mod+8".focus-workspace = 8;
      "Mod+9".focus-workspace = 9;

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

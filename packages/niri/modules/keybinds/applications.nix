{
  flake.nixosModules.wniri-keybinds = {...}: {
    settings.binds = {
      "Mod+Return".spawn = "wezterm";
      "Mod+W".spawn = "brave";

      "Mod+D".spawn = "vesktop";

      "Mod+S".spawn = "pavucontrol";
      "Mod+B".spawn = "blueman-manager";
      "Mod+N".spawn = "nm-connection-editor";

      "Mod+A".spawn-sh = "dms ipc call spotlight toggle";
      "Mod+I".spawn-sh = "dms ipc call settings focusOrToggle";
      "Mod+V".spawn-sh = "dms ipc call clipboard toggle";
      "Mod+Escape".spawn-sh = "dms ipc call powermenu toggle";
      "Mod+Alt+W".spawn-sh = "dms ipc call dankdash wallpaper";
    };
  };
}

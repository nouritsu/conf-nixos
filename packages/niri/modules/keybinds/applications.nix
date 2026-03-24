{
  flake.nixosModules.wniri-keybinds = {...}: {
    settings.binds = {
      "Mod+Return".spawn = "wezterm";
      "Mod+W".spawn = "brave";
    };
  };
}

{...}: {
  programs.waybar.settings.default."hyprland/window" = {
    format = "{}";
    rewrite = {
      "" = "desktop";
      "~" = "terminal";
      "fish" = "terminal";
    };
    swap-icon-label = false;
  };
}

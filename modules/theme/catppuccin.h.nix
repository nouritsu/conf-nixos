{...}: {
  catppuccin = {
    enable = true;
    cache.enable = true;
    flavor = "mocha";
    accent = "mauve";

    bat.enable = true;
    btop.enable = true;
    cursors = {
      enable = true;
      accent = "dark";
    };
    delta.enable = true;
    firefox = {
      enable = true;
      force = true;
      profiles.default = {
        enable = true;
        force = true;
      };
    };
    fish.enable = true;
    fzf.enable = true;
    helix = {
      enable = true;
      useItalics = true;
    };
    hyprland.enable = true;
    hyprlock.enable = false;
    lsd.enable = true;
    starship.enable = true;
    swaync = {
      enable = true;
      font = "JetBrainsMono Nerd Font Propo";
    };
    vesktop.enable = true;
    waybar.enable = false;
    wezterm.enable = true;
    yazi.enable = true;
    zed = {
      enable = true;
      icons.enable = true;
      italics = true;
    };
  };
}

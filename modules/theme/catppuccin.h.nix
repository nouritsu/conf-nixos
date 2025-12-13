{...}: {
  catppuccin = {
    enable = true;
    cache.enable = true;
    flavor = "mocha";
    accent = "mauve";

    bat.enable = true;
    btop.enable = true;
    delta.enable = true;
    # eza.enable = true;
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
    lsd.enable = true;
    starship.enable = true;
    vesktop.enable = true;
    yazi.enable = true;
    zed = {
      enable = true;
      icons.enable = true;
      italics = true;
    };
  };
}

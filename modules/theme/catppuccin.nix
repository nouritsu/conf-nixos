{inputs, ...}: {
  flake = {
    nixosModules.theme-catppuccin = {
      imports = [inputs.catppuccin.nixosModules.catppuccin];

      catppuccin = {
        enable = true;
        cache.enable = true;
        flavor = "mocha";
        accent = "mauve";

        gtk.icon.enable = true;
      };
    };

    homeModules.theme-catppuccin = {
      imports = [inputs.catppuccin.homeModules.catppuccin];

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
        mpv.enable = true;
        starship.enable = true;
        vesktop.enable = true;
        wezterm.enable = true;
        yazi.enable = true;
      };
    };
  };
}

{inputs, ...}: {
  den.aspects.catppuccin.nixos = {
    imports = [inputs.catppuccin.nixosModules.catppuccin];

    catppuccin = {
      enable = true;
      # Enrol every port by default. Upstream is splitting the two knobs:
      # `enable` becomes a global kill switch, `autoEnable` does the enrolling.
      # Setting both keeps today's behaviour once that lands.
      autoEnable = true;
      cache.enable = true;
      flavor = "mocha";
      accent = "mauve";

      gtk.icon.enable = true;
      grub.enable = true;
    };
  };

  den.aspects.catppuccin.homeManager = {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    catppuccin = {
      enable = true;
      autoEnable = true;
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
      # The browser here is Floorp (packages/floorp/floorp.nix), which carries
      # Catppuccin Mocha/Mauve as a force-installed add-on. There is no
      # `programs.firefox` profile for this port to attach to.
      firefox.enable = false;
      fish.enable = true;
      fzf.enable = true;
      hyprlock.enable = false;
      lsd.enable = true;
      mpv.enable = true;
      starship.enable = true;
      wezterm.enable = true;
      zed = {
        enable = true;
        icons.enable = true;
      };
    };
  };
}

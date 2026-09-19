{inputs, ...}: {
  den.aspects.stylix = {
    nixos = {pkgs, ...}: {
      imports = [inputs.stylix.nixosModules.stylix];

      stylix = {
        enable = true;
        targets = {
          grub.enable = false;
          gtk.enable = false;
        };

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.zed-mono;
            name = "ZedMono Nerd Font";
          };
          serif = {
            package = pkgs.overpass;
            name = "Overpass";
          };
          sansSerif = {
            package = pkgs.overpass;
            name = "Overpass";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            applications = 14;
            desktop = 14;
            popups = 12;
            terminal = 14;
          };
        };
      };

      environment.systemPackages = [pkgs.nerd-fonts.jetbrains-mono];
    };

    # Targets whose theming another tool already owns (catppuccin ports, the
    # wrapped packages under packages/, or the zed block in aspects/defaults.nix).
    homeManager.stylix.targets = {
      btop.enable = false;
      firefox.enable = false;
      fish.enable = false;
      helix.enable = false;
      hyprlock.enable = false;
      starship.enable = false;
      vesktop.enable = false;
      yazi.enable = false;
      zed.enable = false;
    };

    provides.catppuccin.nixos = {pkgs, ...}: {
      stylix = {
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      };
    };
  };
}

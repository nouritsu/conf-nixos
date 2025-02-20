{pkgs, ...}: {
  stylix = {
    enable = true;

    image = ../../wallpapers/gruvbox-minimal.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";

    cursor = {
      name = "Capitaine Cursors (Gruvbox)";
      package = pkgs.capitaine-cursors-themed;
      size = 13;
    };

    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Propo";
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
        name = "NotoColorEmoji";
      };

      sizes = {
        applications = 14;
        desktop = 12;
        popups = 10;
        terminal = 14;
      };
    };
  };
}

{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  stylix = {
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
        desktop = 12;
        popups = 10;
        terminal = 14;
      };
    };
  };
}

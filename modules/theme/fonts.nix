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
        desktop = 14;
        popups = 12;
        terminal = 14;
      };
    };
  };
}

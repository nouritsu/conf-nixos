{
  den.aspects.fonts.nixos = {pkgs, ...}: {
    fonts = {
      packages = [
        pkgs.nerd-fonts.zed-mono
        pkgs.nerd-fonts.jetbrains-mono # hyprlock
        pkgs.overpass
        pkgs.noto-fonts-color-emoji
      ];

      fontconfig.defaultFonts = {
        monospace = ["ZedMono Nerd Font"];
        sansSerif = ["Overpass"];
        serif = ["Overpass"];
        emoji = ["Noto Color Emoji"];
      };
    };

    # GTK reads fonts from dconf, not fontconfig; user settings still win
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          font-name = "Overpass 14";
          document-font-name = "Overpass 13";
          monospace-font-name = "ZedMono Nerd Font 14";
        };
      }
    ];
  };
}

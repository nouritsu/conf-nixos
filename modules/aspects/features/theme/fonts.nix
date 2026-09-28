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

    # GTK takes its font from these keys rather than from fontconfig. They sit
    # in a system database, so they are only defaults: anything written to the
    # user database (a settings app, DMS) still wins.
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

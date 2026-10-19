{
  den.aspects.fonts.nixos = {
    self',
    pkgs,
    ...
  }: {
    fonts = {
      packages = [
        self'.packages.maple-mono-nf
        pkgs.nunito
        pkgs.fraunces
        pkgs.noto-fonts-color-emoji
      ];

      fontconfig.defaultFonts = {
        monospace = ["Maple Mono NF"];
        sansSerif = ["Nunito"];
        serif = ["Fraunces 9pt"];
        emoji = ["Noto Color Emoji"];
      };
    };

    # GTK reads fonts from dconf, not fontconfig; user settings still win
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          font-name = "Nunito 14";
          document-font-name = "Fraunces 9pt 13";
          monospace-font-name = "Maple Mono NF 14";
        };
      }
    ];
  };
}

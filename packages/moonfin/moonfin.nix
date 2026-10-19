{
  perSystem = {pkgs, ...}: {
    packages.moonfin = pkgs.appimageTools.wrapType2 (finalAttrs: {
      pname = "moonfin";
      version = "2.7.0";

      src = pkgs.fetchurl {
        url = "https://github.com/Moonfin-Client/Moonfin-Core/releases/download/${finalAttrs.version}/Moonfin_Linux_v${finalAttrs.version}.AppImage";
        hash = "sha256-+X5tE6t1lCh1KxRum2qZRJZ8lxkIq1sxCrlb7B+ExoU=";
      };

      # linked by the bundled flutter, mpv and p11-kit, not in the appimage env
      extraPkgs = pkgs: [
        pkgs.libepoxy
        pkgs.libxv
        pkgs.libffi
      ];

      extraInstallCommands = ''
        install -Dm444 ${finalAttrs.contents}/org.moonfin.linux.desktop -t $out/share/applications
        install -Dm444 ${finalAttrs.contents}/org.moonfin.linux.png -t $out/share/icons/hicolor/512x512/apps
      '';

      passthru.nup = [];

      meta = {
        description = "Jellyfin and Emby media client";
        homepage = "https://moonfin.io";
        license = pkgs.lib.licenses.gpl2Only;
        mainProgram = "moonfin";
        platforms = ["x86_64-linux"];
      };
    });
  };
}

{
  perSystem = {pkgs, ...}: let
    # wants libxdo.so.3; the 4 symbols it imports are unchanged in .4
    # (check with nm -D --undefined-only if this moves)
    libxdo-compat = pkgs.runCommand "libxdo-so-3-compat" {} ''
      mkdir -p $out/lib
      ln -s ${pkgs.xdotool}/lib/libxdo.so.4 $out/lib/libxdo.so.3
    '';
  in {
    packages.splashtop-business = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "splashtop-business";
      version = "3.8.2.0";

      # no repo; URL from Splashtop's support article
      src = pkgs.fetchurl {
        url = "https://download.splashtop.com/linuxclient/splashtop-business_Ubuntu_v${finalAttrs.version}_amd64.tar.gz";
        hash = "sha256-xmi/SH4CbkiKbmuBRyJsSmf33kwxN++dY5uHcRcEzS8=";
      };

      nativeBuildInputs = [
        pkgs.dpkg
        pkgs.autoPatchelfHook
        pkgs.qt5.wrapQtAppsHook
      ];

      buildInputs = [
        pkgs.stdenv.cc.cc.lib # libstdc++, libgcc_s
        pkgs.libcap
        pkgs.keyutils.lib
        pkgs.libpulseaudio
        pkgs.qt5.qtbase
        pkgs.systemdLibs # libudev
        pkgs.util-linux.lib # libuuid
        pkgs.libxcb
        pkgs.libxcb-util
        pkgs.libxcb-keysyms
        libxdo-compat
        pkgs.zlib
      ];

      # ffmpeg is dlopen'd, so autoPatchelf can't see it
      appendRunpaths = [
        "${pkgs.lib.getLib pkgs.ffmpeg}/lib"
      ];

      unpackPhase = ''
        runHook preUnpack
        tar xzf $src
        dpkg-deb -x splashtop-business_Ubuntu_amd64.deb .
        runHook postUnpack
      '';

      dontBuild = true;
      dontConfigure = true;

      installPhase = ''
        runHook preInstall

        # libs resolve relative to the binary, so keep opt/ intact and wrap
        mkdir -p $out/opt $out/bin $out/share/applications $out/share/pixmaps
        cp -r opt/splashtop-business $out/opt/

        ln -s $out/opt/splashtop-business/splashtop-business $out/bin/splashtop-business

        cp usr/share/pixmaps/logo_about_biz.png $out/share/pixmaps/splashtop-business.png

        # upstream hardcodes /usr/bin and /usr/share
        substitute usr/share/applications/splashtop-business.desktop \
          $out/share/applications/splashtop-business.desktop \
          --replace-fail "/usr/bin/splashtop-business" "$out/bin/splashtop-business" \
          --replace-fail "/usr/share/pixmaps/logo_about_biz.png" "splashtop-business"

        install -Dm444 usr/share/bash-completion/completions/splashtop-business \
          $out/share/bash-completion/completions/splashtop-business

        runHook postInstall
      '';

      meta = {
        description = "Remote desktop client for Splashtop Business";
        homepage = "https://www.splashtop.com/";
        license = pkgs.lib.licenses.unfree;
        mainProgram = "splashtop-business";
        platforms = ["x86_64-linux"];
        sourceProvenance = [pkgs.lib.sourceTypes.binaryNativeCode];
      };
    });
  };
}

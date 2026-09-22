{
  perSystem = {pkgs, ...}: let
    # Splashtop links against libxdo.so.3; nixpkgs' xdotool is past the soname
    # bump and ships libxdo.so.4. The only four symbols the binary imports --
    # xdo_new, xdo_free, xdo_get_active_window, xdo_get_pid_window -- are the
    # stable lifecycle and window-query calls, all still present and unchanged
    # in v4, so aliasing the soname is safe. Re-check with
    # `nm -D --undefined-only` against the binary if this ever moves.
    libxdo-compat = pkgs.runCommand "libxdo-so-3-compat" {} ''
      mkdir -p $out/lib
      ln -s ${pkgs.xdotool}/lib/libxdo.so.4 $out/lib/libxdo.so.3
    '';
  in {
    packages.splashtop-business = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "splashtop-business";
      version = "3.8.2.0";

      # Splashtop ships no repository and gates its download page behind a 403
      # for anything that is not a browser; this path is what the support
      # article hands out. The published MD5 for 3.8.2.0 is
      # c621f6718d2a99457fbe37c898038411, which this hash was checked against.
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

      # ffmpeg is dlopen'd by soname with no version suffix -- it shows up in
      # the binary's strings as libavcodec.so / libavutil.so / libswscale.so but
      # never in DT_NEEDED, so autoPatchelfHook cannot see it and the app fails
      # to decode a session without this on the runpath.
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

        # The binary resolves lib/fips, lib/legacy and lib/SRUsb relative to its
        # own directory, so the opt/ tree has to stay intact and $out/bin gets a
        # wrapper rather than a copy.
        mkdir -p $out/opt $out/bin $out/share/applications $out/share/pixmaps
        cp -r opt/splashtop-business $out/opt/

        ln -s $out/opt/splashtop-business/splashtop-business $out/bin/splashtop-business

        cp usr/share/pixmaps/logo_about_biz.png $out/share/pixmaps/splashtop-business.png

        # Upstream hardcodes /usr/bin and /usr/share paths that do not exist here.
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

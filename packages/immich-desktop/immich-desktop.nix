{
  perSystem = {pkgs, ...}: {
    # unofficial qt client for immich
    packages.immich-desktop = pkgs.stdenv.mkDerivation rec {
      pname = "immich-desktop";
      version = "0.2.4";
      src = pkgs.fetchFromGitHub {
        owner = "hdmain";
        repo = "immich-desktop";
        tag = "v${version}";
        hash = "sha256-nSmCEutplu+YgkMgwFSn65LSO0opdqvVHhufkcONHPo=";
      };

      nativeBuildInputs = [
        pkgs.cmake
        pkgs.qt6.qttools
        pkgs.qt6.wrapQtAppsHook
      ];
      buildInputs = [
        pkgs.qt6.qtbase
        pkgs.qt6.qtmultimedia
        pkgs.qt6.qtsvg
        pkgs.qt6.qtwayland
      ];

      # nix does the updating
      cmakeFlags = [(pkgs.lib.cmakeBool "IMMICH_ENABLE_UPDATER" false)];

      passthru.nup = [];

      meta = {
        license = pkgs.lib.licenses.mit;
        mainProgram = "immich";
      };
    };
  };
}

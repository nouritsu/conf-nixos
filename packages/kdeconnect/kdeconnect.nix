{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    # remote input over libei drops the Shift/AltGr a keysym's level needs (kde bug 478262);
    # drop once upstream !1014 ships
    packages.kdeconnect = pkgs.kdePackages.kdeconnect-kde.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          (pkgs.fetchpatch {
            url = "https://invent.kde.org/network/kdeconnect-kde/-/commit/e62b294607e231cfcaa8403181566a52cd97bbfa.patch";
            hash = "sha256-AsoRbSsttCX4yfa3Cqr+7OW2WRGnGUqTXY3SthUewh8=";
          })
        ];
    });

    # RemoteDesktop portal for the mousepad plugin, over niri's virtual pointer/keyboard
    packages.hypr-kdeconnect-fix = pkgs.stdenv.mkDerivation {
      pname = "hypr-kdeconnect-fix";
      version = "0.1.0-${inputs.hypr-kdeconnect-fix.shortRev}";
      src = inputs.hypr-kdeconnect-fix;

      nativeBuildInputs = [pkgs.cmake pkgs.pkg-config pkgs.wayland-scanner];
      buildInputs = [pkgs.qt6.qtbase pkgs.wayland pkgs.libxkbcommon pkgs.libei];

      # tests need a session bus; libei comes from nixpkgs, not the submodule
      cmakeFlags = [(lib.cmakeBool "BUILD_TESTING" false)];
      dontWrapQtApps = true;

      meta.mainProgram = "hypr-kdeconnect-portal";
    };
  };
}

{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    # remote input over libei drops the Shift/AltGr a keysym's level needs (kde bug 478262);
    # drop once upstream !1014 ships
    packages.kdeconnect = let
      fix = pkgs.fetchpatch {
        url = "https://invent.kde.org/network/kdeconnect-kde/-/commit/e62b294607e231cfcaa8403181566a52cd97bbfa.patch";
        hash = "sha256-AsoRbSsttCX4yfa3Cqr+7OW2WRGnGUqTXY3SthUewh8=";
      };
    in
      pkgs.kdePackages.kdeconnect-kde.overrideAttrs (old: {
        # skipped once the source already has it
        postPatch =
          (old.postPatch or "")
          + ''
            if patch -p1 -R --dry-run -s -f <${fix} >/dev/null 2>&1; then
              echo "kdeconnect already has !1014, drop the patch"
            else
              patch -p1 <${fix}
            fi
          '';
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

    # InputCapture portal for share input devices: edge strip, pointer lock, EIS
    packages.xdg-desktop-portal-layercapture = pkgs.callPackage "${inputs.layercapture}/nix/package.nix" {};
  };
}

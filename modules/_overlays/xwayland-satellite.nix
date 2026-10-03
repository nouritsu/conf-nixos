# 0.8.2 breaks X11 popups (Steam menus close as they open)
# drop once nixpkgs is past 0.8.2
# https://github.com/Supreeeme/xwayland-satellite/pull/494
final: prev: {
  xwayland-satellite = prev.xwayland-satellite.overrideAttrs (finalAttrs: _: {
    version = "0.8.2-unstable-2026-09-09";

    src = final.fetchFromGitHub {
      owner = "Supreeeme";
      repo = "xwayland-satellite";
      rev = "add2795134593faafce60e404a0a75df68e9ee0c";
      hash = "sha256-0TxfMgqW0/BLD4M942c5DCKYrtPvzsPJwvdcco4LQUM=";
    };

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src;
      hash = "sha256-s1gl9eR6Mt2QLrhfcowstPFjzwE/lz4PJhJzWYHoIHg=";
    };
  });
}

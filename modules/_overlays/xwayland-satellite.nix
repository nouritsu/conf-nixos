# xwayland-satellite 0.8.2 regressed override-redirect popup placement: the
# Wayland-side hit region stopped matching the X11 geometry, so the pointer reads
# as having left the instant a menu maps and Steam unmaps every popup ~35ms after
# it opens. Fixed upstream in add27951, which is main HEAD with no release cut on
# top of it yet; drop this file once nixpkgs carries anything past 0.8.2.
#
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

    # main added a syslog dependency on top of the 0.8.2 lockfile, so the vendor
    # hash has to move with the source.
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src;
      hash = "sha256-s1gl9eR6Mt2QLrhfcowstPFjzwE/lz4PJhJzWYHoIHg=";
    };
  });
}

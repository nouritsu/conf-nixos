{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # chromium keeps only the last of each switch, so these repeat the wrapper's own
    enable = [
      "AcceleratedVideoDecodeLinuxGL"
      "AcceleratedVideoEncoder"
      "VaapiOnNvidiaGPUs"
    ];
    disable = [
      "OutdatedBuildDetector"
      "UseChromeOSDirectVideoDecoder"
      # calls leave the mic's input level alone
      "WebRtcAllowInputVolumeAdjustment"
    ];
  in {
    packages.brave = pkgs.brave-origin.override {
      commandLineArgs = "--enable-features=${lib.concatStringsSep "," enable} --disable-features=${lib.concatStringsSep "," disable}";
    };
  };
}

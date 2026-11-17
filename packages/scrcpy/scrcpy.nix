{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
    packages.scrcpy = wrappers.lib.wrapPackage ({...}: {
      inherit pkgs;
      package = pkgs.scrcpy;
      flags = {
        "--max-fps" = "120";
        "--video-codec" = "h265";
        "--video-bit-rate" = "16M";

        "--stay-awake" = true;
        "--keep-active" = true; # stay-awake only works while plugged in
        "--power-off-on-close" = true; # turns screen off after scrcpy exit
        "--disable-screensaver" = true;

        # layout picked once on the phone via MOD+k
        "--keyboard" = "uhid";

        "--push-target" = "/sdcard/Shared";
      };
    });
  };
}

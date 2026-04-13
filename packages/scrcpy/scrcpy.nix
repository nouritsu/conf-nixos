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

        "--stay-awake" = true;
        "--turn-screen-off" = true;
        "--power-off-on-close" = true; # turns screen off after scrcpy exit

        "--push-target" = "/sdcard/Shared";
      };
    });
  };
}

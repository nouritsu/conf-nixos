{
  config,
  lib,
  ...
}: let
  is_nvidia = config.my.system.graphics == "nvidia";
in {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = lib.mkIf is_nvidia ["nvidia"];

  hardware.nvidia = lib.mkIf is_nvidia {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}

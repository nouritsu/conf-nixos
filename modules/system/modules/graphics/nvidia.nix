{
  config,
  lib,
  ...
}: let
  is_nvidia = config.my.system.graphics == "nvidia";
in
  lib.mkIf is_nvidia {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  }

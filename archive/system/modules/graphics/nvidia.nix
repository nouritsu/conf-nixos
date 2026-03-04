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
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  }

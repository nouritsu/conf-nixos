{den, ...}: {
  den.aspects.graphics = {
    nixos = {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    provides.nvidia = {
      includes = [
        (den.batteries.unfree [
          "nvidia-x11"
          "nvidia-kernel-modules"
          "nvidia-settings"
          "nvidia-persistenced"
        ])
      ];
      nixos = {
        services.xserver.videoDrivers = ["nvidia"];
        hardware.nvidia = {
          open = false;
          modesetting.enable = true;
        };
      };
    };
  };
}

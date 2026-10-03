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

        # DXVK has no state cache, so keep NVIDIA's shader cache big and uncleaned
        environment.sessionVariables = {
          __GL_SHADER_DISK_CACHE = "1";
          __GL_SHADER_DISK_CACHE_SIZE = "10737418240"; # 10 GiB
          __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
        };
      };
    };

    provides.intel.nixos = {pkgs, ...}: {
      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

      hardware.graphics.extraPackages = [
        pkgs.intel-media-driver
        pkgs.vpl-gpu-rt
      ];

      environment.systemPackages = [pkgs.libva-utils];
    };
  };
}

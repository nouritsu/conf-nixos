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

        # DXVK 2.x has no state cache, so NVIDIA's shader disk cache is the
        # only place DX11 pipelines persist between launches. Defaults are a
        # 1GB budget shared by every Vulkan/GL app plus cleanup that wipes it
        # wholesale rather than pruning (NVIDIA bug 4932793). Must be
        # system-wide — per-game launch options don't survive a reboot.
        environment.sessionVariables = {
          __GL_SHADER_DISK_CACHE = "1";
          __GL_SHADER_DISK_CACHE_SIZE = "10737418240"; # 10 GiB
          __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
        };
      };
    };

    # Integrated Intel graphics: i915/xe come from the kernel, so this only
    # adds the VA-API stack for hardware video decode.
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

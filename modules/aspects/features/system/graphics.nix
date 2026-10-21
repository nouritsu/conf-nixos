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
      nixos = {lib, ...}: {
        services.xserver.videoDrivers = ["nvidia"];
        hardware.nvidia = {
          open = true;
          modesetting.enable = true;
        };

        # by license: cuda redists get renamed between releases
        nixpkgs.config.allowlistedLicenses = lib.attrValues (lib.filterAttrs (name: _: lib.hasPrefix "nvidia" name) lib.licenses);

        # nvidia isn't in the initrd; plymouth ignores the firmware framebuffer unless told
        boot.kernelParams = ["plymouth.use-simpledrm"];

        # usb-c controller on the card; its probe times out every boot
        boot.blacklistedKernelModules = ["i2c_nvidia_gpu"];

        which-key'.menu.s.submenu.v = {
          desc = "NVIDIA settings";
          icon = "f08ae";
          cmd = "nvidia-settings";
          app-id = "nvidia-settings";
        };

        # cudaSupport builds; cache.nixos.org has none
        nix.settings = {
          extra-substituters = ["https://cache.nixos-cuda.org"];
          trusted-public-keys = ["cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="];
        };

        # DXVK has no state cache, so keep NVIDIA's shader cache big and uncleaned
        environment.sessionVariables = {
          __GL_SHADER_DISK_CACHE = "1";
          __GL_SHADER_DISK_CACHE_SIZE = "10737418240"; # 10 GiB
          __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";

          # gtk4's vulkan renderer is slow to start here
          GSK_RENDERER = "gl";

          # skip probing every mesa icd; both arches so 32-bit proton keeps vulkan
          VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json";
        };
      };
    };

    provides.intel.nixos = {pkgs, ...}: {
      # early KMS for the boot splash; udev loads whichever matches the gpu
      boot.initrd.availableKernelModules = ["i915" "xe"];

      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

      hardware.graphics.extraPackages = [
        pkgs.intel-media-driver
        pkgs.vpl-gpu-rt
      ];

      environment.systemPackages = [pkgs.libva-utils];
    };
  };
}

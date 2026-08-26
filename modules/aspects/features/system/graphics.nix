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

{self, ...}: {
  flake.nixosModules = {
    graphics-base = {...}: {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    graphics-nvidia = {...}: {
      imports = [
        self.nixosModules.nixpkgs-unfree
      ];

      services.xserver.videoDrivers = ["nvidia"];

      hardware.nvidia = {
        open = false;
        modesetting.enable = true;
      };
    };
  };
}

{
  flake.nixosModules = {
    extra-printing = {...}: {
      services.printing.enable = true;
    };

    extra-xserver = {pkgs, ...}: {
      services.xserver.enable = true;
      services.xserver.excludePackages = [pkgs.xterm];
    };
  };
}

{
  flake.nixosModules = {
    extra-printing = {...}: {
      services.printing.enable = true;
    };

    extra-xserver = {...}: {
      services.xserver.enable = true;
    };
  };
}

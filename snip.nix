{
  flake.nixosModules.XYZ = {...}: {
    my.hmModules = ["XYZ"];
  };

  flake.homeModules.XYZ = {...}: {
  };
}

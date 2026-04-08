{
  flake.nixosModules.app-explorers = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.nautilus
    ];
  };
}

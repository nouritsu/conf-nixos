{
  den.aspects.nix.update.nixos = {self', ...}: {
    environment.systemPackages = [self'.packages.nup];
  };
}

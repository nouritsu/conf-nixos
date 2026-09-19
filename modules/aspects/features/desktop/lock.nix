{
  den.aspects.lock.nixos = {self', ...}: {
    environment.systemPackages = [self'.packages.hyprlock];
  };
}

{self, ...}: {
  den.aspects.lock.nixos = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    environment.systemPackages = [self.packages.${system}.hyprlock];
  };
}

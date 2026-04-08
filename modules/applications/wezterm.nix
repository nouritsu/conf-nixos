{self, ...}: {
  flake.nixosModules.app-wezterm = {pkgs, ...}: {
    environment.systemPackages = let
      inherit (pkgs.stdenv.hostPlatform) system;
    in [
      self.packages.${system}.wezterm
    ];
  };
}

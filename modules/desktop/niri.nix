{self, ...}: {
  flake.nixosModules.desktop-niri = {pkgs, ...}: {
    programs.niri = let
      inherit (pkgs.stdenv.hostPlatform) system;
    in {
      enable = true;
      package = self.packages.${system}.niri;
    };
  };
}

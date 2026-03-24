{
  inputs,
  self,
  ...
}: let
  inherit (inputs) wrappers niri;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.niri = wrappers.wrappers.niri.wrap [
      {
        inherit pkgs;

        package = let
          inherit (pkgs.stdenv.hostPlatform) system;
        in
          lib.mkForce
          niri.packages.${system}.niri-unstable;
      }

      self.nixosModules.wniri-keybinds
    ];
  };
}

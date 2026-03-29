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
      ({config, ...}: {
        inherit pkgs;

        package = let
          inherit (pkgs.stdenv.hostPlatform) system;
        in
          lib.mkForce
          niri.packages.${system}.niri-unstable;

        passthru.configPath = config."config.kdl".path;
      })

      self.nixosModules.wniri-keybinds
      self.nixosModules.wniri-appearance
      self.nixosModules.wniri-startup
      self.nixosModules.wniri-outputs
    ];
  };
}

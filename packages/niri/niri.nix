{
  inputs,
  self,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
    packages.niri = wrappers.wrappers.niri.wrap [
      ({config, ...}: {
        inherit pkgs;

        passthru.configPath = config."config.kdl".path;
      })
      self.nixosModules.wniri-core
      self.nixosModules.wniri-keybinds
      self.nixosModules.wniri-appearance
      self.nixosModules.wniri-startup
      self.nixosModules.wniri-single-window
      self.nixosModules.wniri-dms
    ];
  };
}

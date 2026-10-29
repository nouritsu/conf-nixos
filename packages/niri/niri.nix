{
  inputs,
  self,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
    packages.niri = wrappers.wrappers.niri.wrap [
      {inherit pkgs;}
      self.nixosModules.wniri-core
      self.nixosModules.wniri-keybinds
      self.nixosModules.wniri-appearance
      self.nixosModules.wniri-startup
      self.nixosModules.wniri-rules
      self.nixosModules.wniri-single-window
      self.nixosModules.wniri-dux
    ];
  };
}

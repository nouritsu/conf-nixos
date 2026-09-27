{
  self,
  inputs,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
    packages.starship = wrappers.wrappers.starship.wrap [
      {
        inherit pkgs;
        package = pkgs.starship;
      }

      self.nixosModules.wstarship-settings
      self.nixosModules.wstarship-theme
    ];
  };
}

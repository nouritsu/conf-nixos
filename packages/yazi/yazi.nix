{
  self,
  inputs,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.yazi = wrappers.wrappers.yazi.wrap [
      {
        inherit pkgs;
        package = inputs'.yazi.packages.default;
        # wrap `ya` too so it sees the same baked config
        wrapperVariants.ya = {};
      }

      self.nixosModules.wyazi-plugins
      self.nixosModules.wyazi-settings
      self.nixosModules.wyazi-keymap
      self.nixosModules.wyazi-init
      self.nixosModules.wyazi-theme
    ];
  };
}

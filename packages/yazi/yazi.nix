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
        # yazi's own wrapper on this nixpkgs: cached binary, no second copy of the previewers
        package = pkgs.callPackage "${inputs.yazi}/nix/yazi.nix" {inherit (inputs'.yazi.packages) yazi-unwrapped;};
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

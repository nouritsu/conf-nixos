{
  self,
  inputs,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.jujutsu = wrappers.wrappers.jujutsu.wrap [
      {
        inherit pkgs;
        package = pkgs.jujutsu;
      }

      self.nixosModules.wgit-identity

      {
        settings = {
          ui = {
            pager = lib.getExe self'.packages.delta;
            diff-formatter = ":git";
          };

          merge-tools.delta.diff-expected-exit-codes = [0 1];
        };
      }
    ];
  };
}

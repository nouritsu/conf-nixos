{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {config, ...}: {
    checks = config.packages;

    treefmt = {
      projectRootFile = "flake.nix";

      programs.alejandra.enable = true;
      programs.deadnix.enable = true;
    };
  };
}

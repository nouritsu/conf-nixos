{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {config, ...}: {
    checks = config.packages;

    treefmt = {
      projectRootFile = "flake.nix";

      # shared with the devenv templates
      imports = [../../templates/base/treefmt.nix];
    };
  };
}

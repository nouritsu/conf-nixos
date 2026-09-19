{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {config, ...}: {
    # Every package is also a check, so `nix flake check` covers the whole set
    # rather than treefmt alone: --no-build evaluates them, a plain run builds
    # them. treefmt contributes checks.treefmt alongside these.
    checks = config.packages;

    treefmt = {
      projectRootFile = "flake.nix";

      # alejandra is already what helix and zed reach for, so `nix fmt` and the
      # editors agree by construction. deadnix edits in place, which means the
      # check fails on any binding nothing reads.
      programs.alejandra.enable = true;
      programs.deadnix.enable = true;
    };
  };
}

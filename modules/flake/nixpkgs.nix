{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.nixpkgs';
in {
  options.nixpkgs' = {
    unfree = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    # matched without the version so bumps keep the permit
    insecure = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    config = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.anything;
      default = {};
    };
  };

  config.nixpkgs'.unfree = ["spotify" "splashtop-business" "claude-code"];

  config.perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      overlays = import ../_overlays inputs;
      config =
        cfg.config
        // {
          allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) cfg.unfree;
          allowInsecurePredicate = pkg:
            lib.elem (lib.getName pkg) cfg.insecure
            && lib.warn "permitting insecure ${lib.getName pkg} ${lib.getVersion pkg}" true;
        };
    };
  };
}

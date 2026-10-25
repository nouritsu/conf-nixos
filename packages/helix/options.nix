{self, ...}: {
  flake.nixosModules.whelix-options = {
    lib,
    pkgs,
    config,
    ...
  }: {
    config._module.args.onDemand = self.lib.onDemand pkgs;

    options.helix' = {
      binds_g = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "TOML keybindings for g minor mode";
      };

      binds_space = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "TOML keybindings for space minor mode";
      };
    };

    config.extraSettings =
      /*
      toml
      */
      ''
        [keys.normal.g]
        ${config.helix'.binds_g}

        [keys.select.g]
        ${config.helix'.binds_g}

        [keys.normal.space]
        ${config.helix'.binds_space}

        [keys.select.space]
        ${config.helix'.binds_space}
      '';
  };
}

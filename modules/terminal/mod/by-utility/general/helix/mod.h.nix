{lib, ...}: {
  options.my.helix = {
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
}

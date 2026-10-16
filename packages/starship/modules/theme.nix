{inputs, ...}: {
  # catppuccin mocha palette, so colour names resolve to it, not ANSI
  flake.nixosModules.wstarship-theme = {lib, ...}: {
    settings =
      {palette = "catppuccin_mocha";}
      // lib.importTOML "${inputs.catppuccin-starship}/themes/mocha.toml";
  };
}

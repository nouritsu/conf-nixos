{inputs, ...}: {
  # catppuccin mocha palette, so colour names resolve to it, not ANSI
  flake.nixosModules.wstarship-theme = {
    lib,
    pkgs,
    ...
  }: let
    sources = inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    settings =
      {palette = "catppuccin_mocha";}
      // lib.importTOML "${sources.starship}/mocha.toml";
  };
}

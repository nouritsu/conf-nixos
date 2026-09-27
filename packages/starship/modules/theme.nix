{inputs, ...}: {
  # catppuccin mocha palette, merged the way the catppuccin-nix home-manager
  # port did: with it, colour names like red/yellow/green/blue/mauve resolve to
  # the palette instead of the terminal's ANSI slots
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

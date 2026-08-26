{inputs, ...}: {
  # catppuccin mocha/mauve, baked in since the catppuccin-nix home-manager
  # target only applies when programs.yazi is enabled there
  flake.nixosModules.wyazi-theme = {
    lib,
    pkgs,
    ...
  }: let
    sources = inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system};
    flavor = lib.importTOML "${sources.yazi}/mocha/catppuccin-mocha-mauve.toml";
  in {
    settings.theme =
      flavor
      // {
        # the flavor expects the tmTheme copied to ~/.config/yazi; point
        # code-preview highlighting at the store instead
        mgr = flavor.mgr // {syntect_theme = "${sources.bat}/Catppuccin Mocha.tmTheme";};
      };
  };
}

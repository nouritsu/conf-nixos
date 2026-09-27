{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  inherit (nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    # catppuccin's mocha theme highlights in blue; mauve is the accent here
    theme = pkgs.runCommand "catppuccin_mocha_mauve.theme" {} ''
      sed \
        -e 's/^theme\[hi_fg\]=.*/theme[hi_fg]="#${palette.base0E}"/' \
        -e 's/^theme\[selected_fg\]=.*/theme[selected_fg]="#${palette.base0E}"/' \
        ${inputs'.catppuccin.packages.btop}/catppuccin_mocha.theme > $out
    '';
  in {
    packages.btop = wrappers.wrappers.btop.wrap [
      {
        inherit pkgs;
        package = pkgs.btop;
      }
      {
        themes.catppuccin_mocha_mauve = theme;

        settings = {
          color_theme = "catppuccin_mocha_mauve.theme";
          theme_background = false;
          proc_tree = true;
          proc_gradient = false;
          update_ms = 1000;

          # --config points into the store, so there is nowhere to save to
          save_config_on_exit = false;
        };
      }
    ];
  };
}

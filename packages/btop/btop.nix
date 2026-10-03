{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  inherit (nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    # mocha highlights in blue; swap in mauve
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

          # config is in the store, nowhere to save
          save_config_on_exit = false;
        };
      }
    ];
  };
}

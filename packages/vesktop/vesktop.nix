{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    name = "catppuccin-mocha-mauve.theme";

    # the dist css tracks Discord's class names, so it stays an import
    theme = pkgs.writeText "${name}.css" ''
      /**
       * @name Catppuccin Mocha (Mauve)
       * @author Catppuccin
       * @description Soothing pastel theme for Discord
       * @website https://github.com/catppuccin/discord
      **/
      @import url("https://catppuccin.github.io/discord/dist/${name}.css");
    '';

    enforce = pkgs.writeShellApplication {
      name = "vesktop-theme";
      runtimeInputs = [pkgs.coreutils pkgs.jq];
      text = ''
        data=''${VENCORD_USER_DATA_DIR:-''${XDG_CONFIG_HOME:-$HOME/.config}/vesktop}
        settings=$data/settings/settings.json

        install -Dm644 ${theme} "$data/themes/${name}.css"

        mkdir -p "''${settings%/*}"
        [[ -s $settings ]] || echo '{}' >"$settings"
        jq '.enabledThemes = ["${name}.css"]' "$settings" >"$settings.tmp"
        mv "$settings.tmp" "$settings"
      '';
    };
  in {
    packages.vesktop = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.vesktop;
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}

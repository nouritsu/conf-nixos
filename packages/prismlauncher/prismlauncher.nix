{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  inherit (nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    themes = pkgs.srcOnly {
      stdenv = pkgs.stdenvNoCC;
      pname = "prismlauncher-themes";
      version = "0-unstable-2026-10-05";
      src = pkgs.fetchFromGitHub {
        owner = "PrismLauncher";
        repo = "Themes";
        rev = "4b2556c54fe7e89b4ec82bc270d3c56644a79d94";
        hash = "sha256-YZxym0sPCjwAmXEnuDL9jUbaTNRCqxiQze1FAMLLp2w=";
      };
      passthru.nup = ["--version=branch"];
    };

    # mocha highlights in lavender; swap in mauve
    theme = pkgs.runCommand "prismlauncher-catppuccin-mocha" {} ''
      cp -r ${themes}/themes/Catppuccin-Mocha $out
      chmod -R u+w $out
      sed -i -E 's/("(Highlight|Link)": )"#[0-9a-fA-F]+"/\1"#${palette.base0E}"/' $out/theme.json
    '';

    enforce = pkgs.writeShellApplication {
      name = "prismlauncher-theme";
      runtimeInputs = [pkgs.coreutils pkgs.gnugrep pkgs.crudini];
      text = ''
        data=''${XDG_DATA_HOME:-$HOME/.local/share}/PrismLauncher
        mkdir -p "$data/themes"
        # Prism's theme id is this directory name
        ln -sfnT ${theme} "$data/themes/Catppuccin-Mocha"

        # no cfg yet means Prism's first-run setup
        # crudini is slow, skip it when already set
        if [[ -f $data/prismlauncher.cfg ]] && ! grep -qx 'ApplicationTheme=Catppuccin-Mocha' "$data/prismlauncher.cfg"; then
          crudini --ini-options=nospace --set "$data/prismlauncher.cfg" \
            General ApplicationTheme Catppuccin-Mocha
        fi
      '';
    };
  in {
    packages.prismlauncher-themes = themes;

    packages.prismlauncher = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        # every instance is 1.12.2
        package = pkgs.prismlauncher.override {jdks = [pkgs.jdk8];};
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}

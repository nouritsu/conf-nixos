{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: let
    port = inputs'.catppuccin.packages.obs;

    # mocha highlights in blue and lavender; swap in mauve
    themes = pkgs.runCommand "obs-catppuccin-themes" {} ''
      mkdir $out
      sed -E 's/var\(--ctp_(blue|lavender|sapphire)\)/var(--ctp_mauve)/g' \
        ${port}/Catppuccin.obt > $out/Catppuccin.obt
      cp ${port}/Catppuccin_Mocha.ovt $out/
    '';

    enforce = pkgs.writeShellApplication {
      name = "obs-theme";
      runtimeInputs = [pkgs.coreutils pkgs.gnugrep pkgs.crudini];
      text = ''
        config=''${XDG_CONFIG_HOME:-$HOME/.config}/obs-studio
        mkdir -p "$config/themes"
        for theme in ${themes}/*; do
          ln -sfn "$theme" "$config/themes/''${theme##*/}"
        done

        # no user.ini yet means OBS's first run, which migrates global.ini
        # crudini is slow, skip it when already set
        if [[ -f $config/user.ini ]] && ! grep -qx 'Theme=com.obsproject.Catppuccin.Mocha' "$config/user.ini"; then
          crudini --ini-options=nospace --set "$config/user.ini" \
            Appearance Theme com.obsproject.Catppuccin.Mocha
        fi
      '';
    };
  in {
    packages.obs-studio = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.wrapOBS {
          plugins = [pkgs.obs-studio-plugins.obs-pipewire-audio-capture];
        };
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}

{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # native Steam app from whichever library has it, under programs.steam's
    # steam-run; extraLibs covers what Steam's own runtime would add
    steamApp = {
      name,
      dir,
      extraLibs ? [],
      setup ? null,
    }:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [pkgs.gnused];
        text = ''
          if ! command -v steam-run >/dev/null; then
            echo "${name}: needs steam-run from programs.steam" >&2
            exit 127
          fi

          steam=''${XDG_DATA_HOME:-$HOME/.local/share}/Steam
          libraries=("$steam")
          if [[ -f $steam/steamapps/libraryfolders.vdf ]]; then
            while IFS= read -r library; do
              libraries+=("$library")
            done < <(sed -nE 's/^[[:space:]]*"path"[[:space:]]+"(.*)"[[:space:]]*$/\1/p' "$steam/steamapps/libraryfolders.vdf")
          fi

          for library in "''${libraries[@]}"; do
            exe=$library/steamapps/common/${dir}/${name}
            if [[ -x $exe ]]; then
              ${lib.optionalString (setup != null) "${lib.getExe setup} || true"}
              ${lib.optionalString (extraLibs != []) "export LD_LIBRARY_PATH=${lib.makeLibraryPath extraLibs}\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"}
              exec steam-run "$exe" "$@"
            fi
          done
          echo "${name}: not installed in any Steam library: ''${libraries[*]}" >&2
          exit 127
        '';
      };

    aseprite-themes = pkgs.srcOnly {
      stdenv = pkgs.stdenvNoCC;
      pname = "catppuccin-aseprite";
      version = "0-unstable-2026-08-16";
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "aseprite";
        rev = "c4c95e3a412526e7b8a94ed85df33b4a9e7cb0e9";
        hash = "sha256-jI30YM2UDP5fAsiF+7iwaNdr2UyEQ+yx5wTEAi3BY04=";
      };
      # skip the rolling `release` tag
      passthru.nup = ["--version=branch" "--version-regex=(0-unstable-.*)"];
    };

    aseprite-theme = pkgs.writeShellApplication {
      name = "aseprite-theme";
      runtimeInputs = [pkgs.coreutils pkgs.crudini];
      text = ''
        config=''${XDG_CONFIG_HOME:-$HOME/.config}/aseprite
        mkdir -p "$config/extensions"
        ln -sfnT ${aseprite-themes}/themes/mocha/catppuccin-theme-mocha "$config/extensions/catppuccin-theme-mocha"

        if [[ -f $config/aseprite.ini ]]; then
          crudini --ini-options=nospace --set "$config/aseprite.ini" \
            theme selected "Catppuccin Theme Mocha"
        fi
      '';
    };
  in {
    packages.catppuccin-aseprite = aseprite-themes;

    packages.aseprite-steam = steamApp {
      name = "aseprite";
      dir = "Aseprite";
      setup = aseprite-theme;
    };
    packages.blender-steam = steamApp {
      name = "blender";
      dir = "Blender";
      # X11 session management, linked by the official build
      extraLibs = [pkgs.libsm pkgs.libice];
    };
  };
}

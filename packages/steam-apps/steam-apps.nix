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
              ${lib.optionalString (extraLibs != []) "export LD_LIBRARY_PATH=${lib.makeLibraryPath extraLibs}\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"}
              exec steam-run "$exe" "$@"
            fi
          done
          echo "${name}: not installed in any Steam library: ''${libraries[*]}" >&2
          exit 127
        '';
      };
  in {
    packages.aseprite-steam = steamApp {
      name = "aseprite";
      dir = "Aseprite";
    };
    packages.blender-steam = steamApp {
      name = "blender";
      dir = "Blender";
      # X11 session management, linked by the official build
      extraLibs = [pkgs.libsm pkgs.libice];
    };
  };
}

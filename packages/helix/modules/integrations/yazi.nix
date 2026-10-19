{self, ...}: {
  flake.nixosModules.whelix-integrations-yazi = {
    lib,
    pkgs,
    ...
  }: let
    # the wrapped one, with its plugins, keymap and theme
    yazi = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.yazi;

    # unsaved buffers ([scratch], new files) fall back to their dir, then cwd
    pick = pkgs.writeShellScript "hx-yazi" ''
      target=$1
      if [ ! -e "$target" ]; then
        target=$(dirname -- "$target")
        [ -d "$target" ] || target=.
      fi
      ${yazi} "$target" --chooser-file=/tmp/yazi-path
      [ -f /tmp/yazi-path ] || exit 0

      # binary picks go to their default app, the rest to helix
      texts=
      while IFS= read -r f || [ -n "$f" ]; do
        case $(${pkgs.file}/bin/file -bL --mime -- "$f") in
          inode/x-empty*) texts+="$f"$'\n' ;;
          *charset=binary*) ${pkgs.util-linux}/bin/setsid -f ${pkgs.xdg-utils}/bin/xdg-open "$f" >/dev/null 2>&1 ;;
          *) texts+="$f"$'\n' ;;
        esac
      done < /tmp/yazi-path

      if [ -n "$texts" ]; then
        printf '%s' "$texts" > /tmp/yazi-path
      else
        rm -f /tmp/yazi-path
      fi
    '';
  in {
    helix'.binds_space =
      /*
      toml
      */
      ''
        e = [
          ":sh rm -f /tmp/yazi-path",
          ":insert-output ${pick} %{buffer_name}",
          ":open %sh{cat /tmp/yazi-path}",
          ":redraw"
        ]
      '';
  };
}

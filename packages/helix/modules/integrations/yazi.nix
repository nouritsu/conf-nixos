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
      exec ${yazi} "$target" --chooser-file=/tmp/yazi-path
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

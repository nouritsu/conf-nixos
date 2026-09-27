{self, ...}: {
  flake.nixosModules.whelix-integrations-yazi = {
    lib,
    pkgs,
    ...
  }: let
    # the wrapped one, with its plugins, keymap and theme
    yazi = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.yazi;
  in {
    helix'.binds_space =
      /*
      toml
      */
      ''
        e = [
          ":sh rm -f /tmp/yazi-path",
          ":insert-output ${yazi} %{buffer_name} --chooser-file=/tmp/yazi-path",
          ":open %sh{cat /tmp/yazi-path}",
          ":redraw"
        ]
      '';
  };
}

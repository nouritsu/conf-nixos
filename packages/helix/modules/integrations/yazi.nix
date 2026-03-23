{
  flake.nixosModules.whelix-integrations-yazi = {
    lib,
    pkgs,
    ...
  }: let
    yazi = lib.getExe pkgs.yazi;
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

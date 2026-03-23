{
  flake.nixosModules.whelix-integrations-lazygit = {
    lib,
    pkgs,
    ...
  }: let
    lazygit = lib.getExe pkgs.lazygit;
  in {
    helix'.binds_space =
      /*
      toml
      */
      ''
        g = [
          ":write-all",
          ":new",
          ":insert-output ${lazygit}",
          ":buffer-close!",
          ":redraw",
          ":reload-all"
        ]
      '';
  };
}

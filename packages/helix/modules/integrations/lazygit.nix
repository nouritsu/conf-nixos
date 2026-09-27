{self, ...}: {
  flake.nixosModules.whelix-integrations-lazygit = {
    lib,
    pkgs,
    ...
  }: let
    # the wrapped one, so it opens with the catppuccin theme
    lazygit = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.lazygit;
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

{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: {
    packages.gh-dash = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.gh-dash;
      }
      ({config, ...}: {
        constructFiles.settings = {
          relPath = "gh-dash.yml";
          content = lib.generators.toYAML {} {
            include = ["${inputs'.catppuccin.packages.gh-dash}/mocha/catppuccin-mocha-mauve.yml"];
          };
        };

        flags."--config" = config.constructFiles.settings.path;
      })
    ];
  };
}

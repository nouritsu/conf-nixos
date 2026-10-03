{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: {
    # libgit2 ignores GIT_CONFIG_GLOBAL, so delta has its own config
    packages.delta = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.delta;
      }
      ({config, ...}: {
        constructFiles.gitconfig = {
          relPath = "delta.gitconfig";
          content = lib.generators.toGitINI {
            include.path = "${inputs'.catppuccin.packages.delta}/catppuccin.gitconfig";
            delta.features = "catppuccin-mocha";
          };
        };

        flags."--config" = config.constructFiles.gitconfig.path;
      })
    ];
  };
}

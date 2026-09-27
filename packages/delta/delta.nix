{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: {
    # delta reads its [delta] section through libgit2, which never looks at the
    # GIT_CONFIG_GLOBAL the git wrapper sets, so it carries a config of its own;
    # the git and jujutsu wrappers point their pagers here.
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

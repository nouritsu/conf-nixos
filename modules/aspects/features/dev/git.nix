{
  den.aspects.git = {
    nixos = {
      self',
      pkgs,
      ...
    }: let
      git = self'.packages.git;
    in {
      environment.systemPackages = [
        self'.packages.delta
        self'.packages.jujutsu
        self'.packages.lazygit
        self'.packages.jjui
        pkgs.fishPlugins.forgit
      ];

      # One git on PATH: the wrapper, carrying identity, the delta pagers and
      # the gh credential helper. Aspects still add system-scope settings
      # through programs.git.config (/etc/gitconfig), as ai does.
      programs.git = {
        enable = true;
        package = git;
      };

      programs.fish.shellAliases.lazyjj = "jjui";

      programs.fish.interactiveShellInit = ''
        # The wrapper sets GIT_CONFIG_GLOBAL only for what it runs; a devShell
        # that brings its own git would otherwise go without identity, the
        # credential helper and delta.
        set -gx GIT_CONFIG_GLOBAL ${git.configuration.constructFiles.gitconfig.outPath}

        # lazygit, then cd to wherever it was when it quit
        function lg
          set -x LAZYGIT_NEW_DIR_FILE ~/.lazygit/newdir
          command lazygit $argv
          if test -f $LAZYGIT_NEW_DIR_FILE
            cd (cat $LAZYGIT_NEW_DIR_FILE)
            rm -f $LAZYGIT_NEW_DIR_FILE
          end
        end
      '';
    };

    # gh keeps its auth token in its config dir and only finds extensions
    # under $XDG_DATA_HOME, so neither wraps cleanly; they stay here.
    homeManager = {pkgs, ...}: {
      programs.gh = {
        enable = true;
        extensions = [
          pkgs.gh-markdown-preview
          pkgs.gh-poi
          pkgs.gh-f
        ];
      };
      programs.gh-dash.enable = true;
    };
  };
}

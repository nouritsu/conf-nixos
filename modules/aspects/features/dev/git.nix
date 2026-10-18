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

      programs.git = {
        enable = true;
        package = git;
      };

      programs.fish.shellAliases.lazyjj = "jjui";

      programs.fish.shellAbbrs = {
        gp = "git push";
        gpu = "git push -u origin HEAD";
        gP = "git pull";
        gsc = "git switch -c";
        gcl = "git clone";
        gst = "git status -sb";
        glog = "git log --oneline --graph --decorate";
        gundo = "git reset --soft HEAD~1";
      };

      programs.fish.interactiveShellInit = ''
        abbr -a gcm --set-cursor 'git commit -m "%"'

        # for devShells that bring their own git
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

        bind ctrl-g 'lg; commandline -f repaint'
      '';
    };

    # gh stays in HM: its token and extensions don't wrap
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

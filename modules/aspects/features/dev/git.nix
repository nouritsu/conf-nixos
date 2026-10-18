{
  den.aspects.git = {
    nixos = {
      self',
      pkgs,
      ...
    }: let
      git = self'.packages.git;

      # gh only looks for extensions in its data dir; token stays in hosts.yml
      ghExtensions = pkgs.linkFarm "gh-extensions" {
        gh-dash = "${self'.packages.gh-dash}/bin";
        gh-f = "${pkgs.gh-f}/bin";
        gh-markdown-preview = "${pkgs.gh-markdown-preview}/bin";
        gh-poi = "${pkgs.gh-poi}/bin";
      };
    in {
      environment.systemPackages = [
        self'.packages.delta
        self'.packages.jujutsu
        self'.packages.lazygit
        self'.packages.jjui
        self'.packages.gh-dash
        pkgs.gh
        pkgs.fishPlugins.forgit
      ];

      systemd.user.tmpfiles.rules = ["L+ %h/.local/share/gh/extensions - - - - ${ghExtensions}"];

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
  };
}

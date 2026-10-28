{
  den.aspects.shell.nixos = {
    self',
    pkgs,
    lib,
    ...
  }: let
    tvInit = pkgs.runCommand "tv-init.fish" {} ''
      HOME=$TMPDIR ${self'.packages.television}/bin/tv init fish > $out
      # enter picks instead of running a channel's action (git-branch checks out)
      substituteInPlace $out --replace-fail \
        '--autocomplete-prompt "$current_prompt"' \
        "--autocomplete-prompt \"\$current_prompt\" --keybindings 'enter=\"confirm_selection\"'"
    '';
  in {
    environment.systemPackages = [
      self'.packages.btop
      self'.packages.tealdeer
      self'.packages.television

      pkgs.fishPlugins.done
      pkgs.fishPlugins.autopair
      pkgs.fishPlugins.sponge
      pkgs.fishPlugins.humantime-fish
    ];

    which-key'.menu.s.submenu.r = {
      desc = "btop";
      icon = "f0a07";
      cmd = "${lib.getExe self'.packages.wezterm} start --class btop -- ${lib.getExe self'.packages.btop}";
      app-id = "^btop$";
    };

    # after zoxide's init, which defines its own zi
    programs.fish.interactiveShellInit = lib.mkOrder 1600 ''
      # ctrl-t completes from a channel picked by the command, ctrl-r history
      source ${tvInit}

      function __tv_insert
          printf "\n"
          set -l picks (tv $argv --inline --no-status-bar --keybindings 'enter="confirm_selection"')
          if set -q picks[1]
              commandline -i -- (string join ' ' -- (string escape -- $picks))' '
          end
          printf "\033[A"
          commandline -f repaint
      end

      # fzf.fish keys
      bind ctrl-alt-f '__tv_insert files'
      bind ctrl-alt-l '__tv_insert git-log'
      bind ctrl-alt-s '__tv_insert git-diff'
      bind ctrl-alt-p '__tv_insert procs'
      bind ctrl-v "__tv_insert env --source-output '{split:=:0}'"

      # zoxide's zi needs fzf
      function zi
          set -l dir (tv zoxide --input "$argv" --keybindings 'enter="confirm_selection"')
          and set -q dir[1]
          and z $dir
      end
    '';

    # native fish instead of fenv spawning bash at every start
    programs.fish.useBabelfish = true;

    # apropos and man -k; indexed by a service, not on every rebuild
    documentation.man.cache = {
      enable = true;
      generateAtRuntime = true;
    };

    # bat leaves man's own escapes in unless told to strip them
    environment.variables.MANPAGER = "${lib.getExe pkgs.bat} -plman --theme=ansi --strip-ansi=always";

    # man pages only: no /share/doc outputs or nixos html manual
    documentation.doc.enable = false;
    documentation.nixos.enable = false;
  };
}

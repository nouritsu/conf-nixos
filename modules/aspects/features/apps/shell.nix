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
      # ctrl-r is atuin's
      substituteInPlace $out --replace-fail 'bind --mode $mode ctrl-r tv_shell_history' ""
    '';

    atuinInit = pkgs.runCommand "atuin-init.fish" {} ''
      HOME=$TMPDIR ${self'.packages.atuin}/bin/atuin init fish --disable-up-arrow > $out
    '';

    # one autoloaded file per command carapace knows; fish reads */generated_completions after its builtin ones
    carapaceFish = pkgs.runCommand "carapace-fish" {nativeBuildInputs = [pkgs.carapace];} ''
      export HOME=$TMPDIR
      mkdir -p $out/generated_completions $out/functions
      carapace _carapace fish | sed -n '/^function _carapace_completer$/,/^end$/p' > $out/functions/_carapace_completer.fish
      test -s $out/functions/_carapace_completer.fish
      carapace --list --names | grep -E '^[[:alnum:]][[:alnum:]._+-]*$' | while read -r cmd; do
        echo "complete -c $cmd -f -a '(_carapace_completer $cmd)'" > $out/generated_completions/$cmd.fish
      done
    '';
  in {
    environment.systemPackages = [
      self'.packages.atuin
      self'.packages.btop
      self'.packages.tealdeer
      self'.packages.television
      # its completer calls carapace from PATH
      pkgs.carapace
      pkgs.halp
      # syscalls, libc and posix
      pkgs.man-pages
      pkgs.man-pages-posix

      pkgs.fishPlugins.done
      pkgs.fishPlugins.autopair
      pkgs.fishPlugins.sponge
      pkgs.fishPlugins.fish-bd
      pkgs.fishPlugins.bang-bang
      self'.packages.replay-fish
    ];

    programs.pay-respects.enable = true;

    which-key'.menu.s.submenu.r = {
      desc = "btop";
      icon = "f0a07";
      cmd = "${lib.getExe self'.packages.wezterm} start --class btop -- ${lib.getExe self'.packages.btop}";
      app-id = "^btop$";
    };

    # after zoxide's init, which defines its own zi
    programs.fish.interactiveShellInit = lib.mkOrder 1600 ''
      # ctrl-t completes from a channel picked by the command
      source ${tvInit}

      # ctrl-r, up stays fish's
      source ${atuinInit}

      # carapace only where fish and the packages have nothing, ahead of the man page guesses
      set -l i (contains -i -- /etc/fish/generated_completions $fish_complete_path)
      set fish_complete_path $fish_complete_path[..(math $i - 1)] ${carapaceFish}/generated_completions $fish_complete_path[$i..]
      set -a fish_function_path ${carapaceFish}/functions

      set -g BD_OPT insensitive

      # cheat.sh: cht tar, cht rust iterators
      function cht
          curl -s "cht.sh/$(string join / -- $argv[1] (string join + -- $argv[2..]))"
      end

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

    programs.fish.shellAliases.cheat = "cht";

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

    isup'.checks.atuin = {
      name = "Atuin sync";
      group = "Homelab";
      url = self'.packages.atuin.configuration.settings.sync_address;
    };
  };
}

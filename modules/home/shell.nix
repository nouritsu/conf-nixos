{
  pkgs,
  user,
  ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set SYS_FLAKE "$HOME/.config/nixos"

      set fish_greeting
      starship init fish | source

      # Aliases
      alias calc='eva'
      alias calculator='eva'
      alias cheat='navi'
      alias cheatsheet='navi'

      alias unset='set -e'
      alias cat='bat'
      alias top='btop'
      alias du='dust'
      alias ls='eza --sort=extension --icons=auto --group-directories-first --mounts'
      alias ll='ls -hla --git --git-repos --total-size'
      alias tree='eza --tree'
      alias gtree='eza --tree --git --git-repos --git-ignore'
      alias grep='rg'
      alias grepa='rga'
      alias rm='rip'
      alias awk='frawk'
      alias cp='xcp'
      alias diff='delta'
      alias find='fd'
      alias xxd='hexyl'
      alias hexdump='hexyl'
      alias wtime='hyperfine --runs 1 --warmup 3'
      alias bench='hyperfine --runs 5 --warmup 3'
      alias jq='jql'
      alias fm='yazi'

      alias nhrb='nh os boot $SYS_FLAKE'
      alias nhrs='nh os switch $SYS_FLAKE'
      alias nhca='nh clean all'
      alias nhs='nh search'
    '';

    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }

      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }

      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }

      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }

      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }

      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }

      {
        name = "humantime-fish";
        src = pkgs.fishPlugins.humantime-fish.src;
      }

      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }

      {
        name = "fish-you-should-use";
        src = pkgs.fishPlugins.fish-you-should-use.src;
      }
    ];
  };
}

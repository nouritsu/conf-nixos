{
  pkgs,
  lib,
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
  };
  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = let
    packages = with pkgs; [
      bash

      fzf
      git
    ];
    fish_plugins = with pkgs.fishPlugins; [
      z
      fzf-fish
      done
      forgit
      autopair
      sponge
      humantime-fish
      colored-man-pages
      fish-you-should-use
    ];
  in
    packages ++ fish_plugins;
}

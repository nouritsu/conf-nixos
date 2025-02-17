{
  pkgs,
  user,
  ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Environment Variables
      set fish_greeting
      set SYS_FLAKE "$HOME/.config/nixos"
      set EDITOR "hx"

      # Any Nix Shell
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';

    shellAliases = {
      # NixOS
      nhrb = "nh os boot $SYS_FLAKE";
      nhrs = "nh os switch $SYS_FLAKE";
      nhca = "nh clean all";
      nhs = "nh search";

      # Fish
      unset = "set -e";
      whereami = "echo $hostname";

      # Core
      cat = "bat";
      top = "btop";
      du = "dust";
      rm = "rip";
      awk = "frawk";
      cp = "xcp";
      diff = "delta";
      find = "fd -HI";
      findg = "fd -H";
      ps = "procs";
      sed = "sd";
      tr = "sd";

      # CD
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # ls/tree
      ls = "eza --sort=extension --icons=auto --group-directories-first --mounts";
      l = "ls -hla --total-size";
      ll = "l --git --git-repos";
      tree = "ll --tree";
      lg = "ll --git-ignore";
      treeg = "tree --git --git-repos --git-ignore";

      # Helix
      helix = "hx";
      vi = "hx";
      vim = "hx";
      nvim = "hx";

      # Calculator
      calc = "eva";
      calculator = "eva";

      # Cheatsheet
      cheat = "navi";
      cheatsheet = "navi";

      # Hexdump
      xxd = "hexyl";
      hexdump = "hexyl";

      # Grep
      grep = "rg";
      grepa = "rga";

      # Timing
      wtime = "hyperfine --runs 1 --warmup 3";
      bench = "hyperfine --runs 5 --warmup 3";

      # Fetch
      neofetch = "fastfetch";
      nerdfetch = "fastfetch";

      # Other
      jq = "jql";
      fm = "yazi";
      code-count = "tokei ./";

      # Youtube Downloader
      youtube-dl = "yt-dlp";
      yt-dl = "yt-dlp";

      # Spotify Downloader
      spotify-dl = "spotdl";
      sp-dl = "spotdl";

      # Internet
      speedtest = "speedtest-rs";
      vpn = "mullvad";
      vpn-closest = "mullvad-closest --max-distance 500 --server-type wireguard";
    };

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

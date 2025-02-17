{
  pkgs,
  user,
  ...
}: {
  programs.fish = let
    get-pkg-bin = name: bin: "${pkgs.${name}}/bin/${bin}";
    get-pkg = name: get-pkg-bin name name;
  in {
    enable = true;
    interactiveShellInit = ''
      # Environment Variables
      set fish_greeting
      set SYS_FLAKE "$HOME/.config/nixos"
      set EDITOR "hx"

      # Any Nix Shell
      ${get-pkg "any-nix-shell"} fish --info-right | source
    '';

    shellAliases = {
      # NixOS
      nhrb = "${get-pkg "nh"} os boot $SYS_FLAKE";
      nhrs = "${get-pkg "nh"} os switch $SYS_FLAKE";
      nhca = "${get-pkg "nh"} clean all";
      nhs = "${get-pkg "nh"} search";

      # Fish
      unset = "set -e";
      whereami = "echo $hostname";

      # Core
      cd = "z"; # zoxide, but not directly a package
      cat = "${get-pkg "bat"}";
      top = "${get-pkg "btop"}";
      du = "${get-pkg "dust"}";
      rm = "${get-pkg-bin "rip2" "rip"}";
      awk = "${get-pkg "frawk"}";
      cp = "${get-pkg "xcp"}";
      diff = "${get-pkg "delta"}";
      find = "${get-pkg "fd"} -HI";
      findg = "${get-pkg "fd"} -H";
      ps = "${get-pkg "procs"}";
      sed = "${get-pkg "sd"}";
      tr = "${get-pkg "sd"}";

      # CD
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # ls/tree
      ls = "${get-pkg "eza"} --sort=extension --icons=auto --group-directories-first --mounts";
      l = "ls -hla --total-size";
      ll = "l --git --git-repos";
      tree = "ll --tree";
      lg = "ll --git-ignore";
      treeg = "tree --git --git-repos --git-ignore";

      # Helix
      helix = "${get-pkg "helix"}";
      vi = "helix";
      vim = "helix";
      nvim = "helix";

      # Calculator
      calc = "${get-pkg "eva"}";
      calculator = "calc";

      # Cheatsheet
      cheat = "${get-pkg "navi"}";
      cheatsheet = "cheat";

      # Hexdump
      xxd = "${get-pkg "hexyl"}";
      hexdump = "xxd";

      # Grep
      grep = "${get-pkg-bin "ripgrep" "rg"}";
      grepa = "${get-pkg-bin "ripgrep-all" "rga"}";

      # Timing
      wtime = "${get-pkg "hyperfine"} --runs 1 --warmup 3";
      bench = "${get-pkg "hyperfine"} --runs 5 --warmup 3";

      # Fetch
      neofetch = "${get-pkg "fastfetch"}";
      nerdfetch = "${get-pkg "fastfetch"}";

      # JQL
      jq = "${get-pkg "jql"}";

      # Yazi
      fm = "${get-pkg "yazi"}";

      # Tokei
      code-count = "${get-pkg "tokei"}";
      count-lines = "code-count";
      lines-count = "code-count";

      # Glow
      view-md = "${get-pkg "glow"}";
      md-view = "view-md";

      # Youtube Downloader
      youtube-dl = "${get-pkg "yt-dlp"}";
      yt-dl = "youtube-dl";

      # Spotify Downloader
      spotify-dl = "${get-pkg "spotdl"}";
      sp-dl = "spotify-dl";

      # Internet
      speedtest = "${get-pkg "speedtest-rs"}";
      vpn = "${get-pkg-bin "mullvad-vpn" "mullvad"}";
      vpn-closest = "${get-pkg "mullvad-closest"} --max-distance 500 --server-type wireguard";
      browser = "${get-pkg "browsh"}";
      browse = "browser";

      # Snippets
      snippets = "${get-pkg "nap"}";
      snips = "snippets";
      snip = "snippets";
    };

    plugins = [
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

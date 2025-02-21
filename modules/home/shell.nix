{
  pkgs,
  lib,
  ...
}: {
  programs.fish = let
    get-pkg-bin = name: bin: "${pkgs.${name}}/bin/${bin}";
    get-pkg = name: get-pkg-bin name name;
    supported-languages.regex =
      "("
      + lib.concatStrings (builtins.map
        (lang: "^" + lang + "(\\s)+" + "|")
        [
          "bash"
          "c"
          "cpp"
          "cmake"
          "dart"
          "dockerfile"
          "dot"
          "fish"
          "gdscript"
          "go"
          "haskell"
          "javascript"
          "java"
          "json"
          "kotlin"
          "latex"
          "lua"
          "markdown"
          "nix"
          "glsl"
          "perl"
          "prolog"
          "python"
          "rust"
          "sql"
          "typescript"
          "vhdl"
          "wgsl"
          "yaml"
        ]
        ++ ["zig"]) # in my defence, it looked cool
      + ")";
  in {
    enable = true;
    interactiveShellInit = ''
      # Environment Variables
      set fish_greeting
      set FLAKE "$HOME/.config/nixos"
      set WIN_BIN = "/mnt/c/NixOS/bin"

      ## $PATH
      fish_add_path $WIN_BIN

      # Any Nix Shell
      ${get-pkg "any-nix-shell"} fish --info-right | source
    '';

    shellAliases = {
      # NixOS
      nix = "${get-pkg-bin "nix-output-monitor" "nom"}";
      nhrb = "${get-pkg "nh"} os boot $FLAKE";
      nhrs = "${get-pkg "nh"} os switch $FLAKE";
      nhrt = "${get-pkg "nh"} os test $FLAKE";
      nhca = "${get-pkg "nh"} clean all";
      nhs = "${get-pkg "nh"} search";
      conf-edit = "$EDITOR $FLAKE";
      config = "conf-edit";

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
      helix = "${get-pkg-bin "helix" "hx"}";
      vi = "helix";
      vim = "helix";
      nvim = "helix";
      hx-health = "helix --health | ${pkgs.ripgrep}/bin/rg \"${supported-languages.regex}\"";

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

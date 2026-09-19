{
  den.aspects.core.nixos = {
    self',
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = [
      self'.packages.wezterm
      self'.packages.floorp
      pkgs.nautilus

      # fish comes from den battery
      pkgs.fish-lsp
      pkgs.any-nix-shell

      pkgs.uutils-coreutils-noprefix
      pkgs.killall
      pkgs.lsd
      pkgs.xcp
      pkgs.rip2
      pkgs.bat
      pkgs.fd
      pkgs.fzf
      pkgs.ripgrep
      pkgs.ripgrep-all
      pkgs.tealdeer
      pkgs.gnutar
      pkgs.ouch
      pkgs.unzip
      pkgs.eva
      pkgs.hyperfine
      pkgs.dust
    ];

    programs.zoxide.enable = true;

    programs.fish.interactiveShellInit = ''
      set fish_greeting
      any-nix-shell fish --info-right | source
    '';

    programs.fish.shellAliases = {
      ls = "lsd -F --total-size --group-directories-first --hyperlink auto --git --extensionsort --classify";
      l = "ls -1";
      ll = "ls -lA";
      lr = "ll --recursive";
      tree = "ls --tree";

      top = "btop";
      bottom = "btop";

      find = "fd --no-ignore";
      findh = "find --hidden";
      findg = "fd";
      findhg = "findg --hidden";

      calculator = "eva";
      calc = "eva";

      wtime = "hyperfine --runs 1 --warmup 3 --";
      bench = "hyperfine --runs 5 --";
      wbench = "hyperfine --runs 5 --warmup 3 --";

      grep = "rg";
      grepa = "rga";

      cat = "bat --theme=ansi"; # inherit terminal theme
      cp = "xcp";
      rm = "rip";
      cd = "z";
      fz = "fzf";
      du = "dust";
    };

    programs.fish.shellAbbrs = let
      cd_abbr_count = 7;
    in
      {
        compress = "ouch compress";
        decompress = "ouch decompress";
      }
      // lib.listToAttrs (
        map (n: {
          name = lib.concatStrings (lib.genList (_: ".") n); # n dots
          value = "cd ${lib.concatStringsSep "/" (lib.genList (_: "..") (n - 1))}"; # prev_dir based on n
        }) (lib.range 2 (cd_abbr_count + 1))
      );
  };
}

{self, ...}: {
  flake.nixosModules = {
    app-core = {
      pkgs,
      lib,
      ...
    }: {
      home-manager.users.aneesh.imports = [self.homeModules.app-core];

      environment.systemPackages = with pkgs; [
        uutils-coreutils-noprefix
        killall
        lsd
        xcp
        rip2
        bat
        fd
        fzf
        ripgrep
        ripgrep-all
        tealdeer
        gnutar
        ouch
        unzip
        eva
        hyperfine
        dust

        # TODO: find a better place for these
        sops
        nix-output-monitor
      ];

      programs.zoxide.enable = true;

      programs.fish.shellAliases = {
        # ls
        ls = "lsd -F --total-size --group-directories-first --hyperlink auto --git --extensionsort --classify";
        l = "ls -1";
        ll = "ls -lA";
        lr = "ll --recursive";
        tree = "ls --tree";

        # btop
        top = "btop";
        bottom = "btop";

        # find
        find = "fd --no-ignore";
        findh = "find --hidden";
        findg = "fd";
        findhg = "findg --hidden";

        # eva
        calculator = "eva";
        calc = "eva";

        # hyperfine
        wtime = "hyperfine --runs 1 --warmup 3 --";
        bench = "hyperfine --runs 5 --";
        wbench = "hyperfine --runs 5 --warmup 3 --";

        # rg / rga
        grep = "rg";
        grepa = "rga";

        cat = "bat --theme=ansi"; # inherit terminal theme
        cp = "xcp";
        rm = "rip";
        cd = "z";
        fz = "fzf";
        du = "dust";
      };

      # form: abbr = expansion
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
  };

  flake.homeModules.app-core = {...}: {
    programs.man = {
      enable = true;
      generateCaches = true;
    };

    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
        proc_tree = true;
        proc_gradient = false;
        update_ms = 1000;
      };
    };

    programs.tealdeer = {
      enable = true;
      settings.updates = {
        auto_update = true;
        auto_update_interval_hours = 24;
      };
    };
  };
}

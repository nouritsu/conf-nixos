{den, ...}: {
  den.aspects.core.nixos = {
    self',
    config,
    pkgs,
    lib,
    ...
  }: let
    other = lib.head (lib.remove config.networking.hostName (lib.attrNames den.hosts.x86_64-linux));

    zoxideInit = pkgs.runCommand "zoxide-init.fish" {} ''
      ${lib.getExe config.programs.zoxide.package} init fish > $out
    '';

    nixYourShellInit = pkgs.runCommand "nix-your-shell-init.fish" {} ''
      ${lib.getExe pkgs.nix-your-shell} fish > $out
    '';
  in {
    environment.systemPackages = [
      self'.packages.wezterm

      # fish comes from den battery
      pkgs.fish-lsp
      pkgs.nix-your-shell

      pkgs.uutils-coreutils-noprefix
      pkgs.killall
      pkgs.lsd
      pkgs.xcp
      pkgs.rip2
      pkgs.bat
      pkgs.fd
      pkgs.ripgrep
      pkgs.ripgrep-all
      pkgs.ouch
      pkgs.unzip
      pkgs.eva
      pkgs.hyperfine
      pkgs.dust
      pkgs.duf
      pkgs.prettyping
      pkgs.doggo
      pkgs.rsync

      pkgs.powertop
      pkgs.nvtopPackages.full
      pkgs.procs
      pkgs.systemctl-tui
    ];

    # setcap wrappers
    programs.iotop = {
      enable = true;
      package = pkgs.iotop-c;
      enableDelayacct = true;
    };
    programs.bandwhich.enable = true;
    programs.wavemon.enable = true;

    programs.zoxide = {
      enable = true;
      enableFishIntegration = false;
    };

    # gio and the portal start Terminal=true apps like helix through it
    xdg.terminal-exec = {
      enable = true;
      settings.default = ["org.wezfurlong.wezterm.desktop"];
    };

    programs.fish.interactiveShellInit = ''
      set fish_greeting
      source ${nixYourShellInit}
      source ${zoxideInit}

      function mkcd
        mkdir -p $argv[1]; and cd $argv[1]
      end

      # builtin: keeps temp dirs out of zoxide
      function mktempd
        builtin cd (mktemp -d)
      end

      # novpn, else wttr.in places you at the proton exit
      function weather
        ${lib.getExe self'.packages.novpn} curl -s "wttr.in/$(string join + -- $argv)?mF"
      end

      # same path on the other machine, never over a newer file
      function ship
        rsync -aRh --update --info=progress2 -- (path resolve $argv) ${other}.local:/
      end

      # ctrl-z back into the suspended job, alt-z for zoxide's picker
      bind ctrl-z 'fg 2>/dev/null; commandline -f repaint'
      bind alt-z 'zi; commandline -f repaint'

      abbr -a --position anywhere -- --help '--help &| bat -plhelp --theme=ansi'
    '';

    programs.fish.shellAliases = {
      ls = "lsd -F --total-size --group-directories-first --hyperlink auto --git --extensionsort --classify";
      l = "ls -1";
      ll = "ls -lA";
      lr = "ll --recursive";
      tree = "ls --tree";

      top = "btop";
      bottom = "btop";
      top-power = "sudo powertop";
      top-gpu = "nvtop";
      top-io = "iotop";
      top-net = "bandwhich";
      top-ram = "procs --watch --sortd rss";
      top-sys = "systemctl-tui";
      top-audio = "pw-top";
      top-wifi = "wavemon";

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
      fz = "tv";
      du = "dust";
      df = "duf";
      ping = "prettyping";
      dig = "doggo";
    };

    programs.fish.shellAbbrs = let
      cd_abbr_count = 7;
    in
      {
        compress = "ouch compress";
        decompress = "ouch decompress";

        sc = "sudo systemctl";
        scu = "systemctl --user";
        jf = "journalctl -fu";
        jfu = "journalctl --user -fu";
      }
      // lib.listToAttrs (
        map (n: {
          name = lib.concatStrings (lib.genList (_: ".") n); # n dots
          value = "cd ${lib.concatStringsSep "/" (lib.genList (_: "..") (n - 1))}"; # prev_dir based on n
        }) (lib.range 2 (cd_abbr_count + 1))
      );
  };
}

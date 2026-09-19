{den, ...}: {
  den.aspects.extra.provides = {
    media = {
      includes = [(den.batteries.unfree ["spotify"])];
      nixos = {
        self',
        pkgs,
        ...
      }: {
        environment.systemPackages = [
          pkgs.ffmpeg-full
          pkgs.obs-studio
          pkgs.eog
          pkgs.mpv
          self'.packages.spotify
        ];
      };
    };

    pdf.nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.pdftk
        pkgs.poppler-utils
        pkgs.pdfchain
        pkgs.kdePackages.okular
        pkgs.zathura
        pkgs.zathuraPkgs.zathura_pdf_mupdf
      ];
    };

    download.nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.wget2
        pkgs.axel
        pkgs.yt-dlp
        pkgs.spotdl
        pkgs.speedtest-rs
      ];

      programs.fish.shellAliases = {
        download = "axel";
        speedtest = "speedtest-rs";
        download-youtube = "yt-dlp";
        download-yt = "yt-dlp";
        download-spotify = "spotdl";
        download-spot = "spotdl";
      };
    };

    productivity.nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.anki pkgs.drawio];
    };

    fetchers = {
      includes = [
        (den.batteries.unfree [
          "cuda_cccl"
          "cuda_cudart"
          "cuda_nvcc"
          "cuda_nvml_dev"
        ])
      ];
      nixos = {
        self',
        inputs',
        pkgs,
        config,
        lib,
        ...
      }: let
        is_nvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
      in {
        environment.systemPackages = [
          pkgs.nerdfetch
          pkgs.fastfetch
          pkgs.onefetch
          pkgs.cpufetch
          (pkgs.gpufetch.override {cudaSupport = is_nvidia;})
          self'.packages.ifetch
          self'.packages.mfetch
          inputs'.batfetch.packages.default
        ];

        programs.fish.shellAliases = {
          fetch = "nerdfetch";
          fetch-full = "fastfetch";
          fetch-git = "onefetch";
          fetch-cpu = "cpufetch";
          fetch-gpu = "gpufetch";
          fetch-mem = "mfetch";
          fetch-net = "ifetch";
          fetch-bat = "batfetch";
        };
      };
    };

    tui-viewers.nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.binsider
        pkgs.hexyl
        pkgs.glow
      ];

      programs.fish.shellAliases = let
        b = "binsider";
      in {
        view-elf = b;
        view-bin = b;
        view-bytes = "hexyl";
        hexdump = "hexyl";
        view-md = "glow";
      };
    };

    chat = {
      includes = [(den.batteries.unfree ["slack"])];
      nixos = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.telegram-desktop
          pkgs.whatsapp-electron
          pkgs.vesktop
          pkgs.teams-for-linux
          pkgs.slack
        ];
      };
    };

    gaming = {
      includes = [(den.batteries.unfree ["steam" "steam-unwrapped" "steam-original" "steam-run"])];
      nixos = {pkgs, ...}: {
        programs.steam = {
          enable = true;
          extest.enable = true;
          gamescopeSession.enable = true;
        };
        programs.gamemode.enable = true;

        environment.systemPackages = [
          pkgs.mangohud
          pkgs.protonup-ng
          pkgs.lumafly
          pkgs.r2modman
          pkgs.satisfactorymodmanager
          pkgs.eden
          pkgs.prismlauncher
          pkgs.deadlock-mod-manager
        ];

        environment.variables = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
        };
      };
    };

    proton = {
      includes = [(den.batteries.unfree ["proton-authenticator"])];
      nixos = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.proton-authenticator
          pkgs.protonmail-desktop
          pkgs.proton-pass
          pkgs.proton-vpn
        ];
      };
    };
  };
}

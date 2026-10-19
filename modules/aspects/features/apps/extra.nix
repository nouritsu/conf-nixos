{den, ...}: {
  den.aspects.extra.provides = {
    media = {
      nixos = {
        self',
        pkgs,
        lib,
        ...
      }: {
        environment.systemPackages = [
          pkgs.ffmpeg-full
          self'.packages.obs-studio
          pkgs.eog
          self'.packages.mpv
          self'.packages.spotify
          self'.packages.moonfin
        ];

        xdg.mime.defaultApplications =
          # brave and papers claim some of these otherwise
          lib.genAttrs [
            "image/jpeg"
            "image/pjpeg"
            "image/png"
            "image/gif"
            "image/webp"
            "image/avif"
            "image/heic"
            "image/jxl"
            "image/bmp"
            "image/x-bmp"
            "image/tiff"
            "image/svg+xml"
          ] (_: "org.gnome.eog.desktop")
          # umpv claims these too
          // lib.genAttrs [
            "video/mp4"
            "video/x-matroska"
            "video/webm"
            "video/quicktime"
            "video/x-msvideo"
            "video/mpeg"
            "video/ogg"
            "video/x-flv"
            "video/3gpp"
            "video/mp2t"
            "audio/mpeg"
            "audio/flac"
            "audio/ogg"
            "audio/opus"
            "audio/wav"
            "audio/x-wav"
            "audio/mp4"
            "audio/aac"
            "audio/x-m4a"
          ] (_: "mpv.desktop");

        # v4l2loopback only; obs itself is installed above
        programs.obs-studio = {
          enable = true;
          package = null;
          enableVirtualCamera = true;
        };
      };
    };

    pdf.nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.pdftk
        pkgs.poppler-utils
        pkgs.pdfchain
        pkgs.papers
      ];

      # brave, xournalpp and onlyoffice claim it otherwise
      xdg.mime.defaultApplications."application/pdf" = "org.gnome.Papers.desktop";
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

    productivity.nixos = {
      self',
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        pkgs.anki
        pkgs.drawio
        self'.packages.splashtop-business
      ];
    };

    fetchers = {
      includes = [
        (den.batteries.unfree [
          "cccl"
          "cuda_crt"
          "cuda_cudart"
          "cuda_nvcc"
          "cuda_nvml_dev"
          "libnvvm"
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
          # cuda 13 removed the clock fields from cudaDeviceProp
          # https://github.com/Dr-Noob/gpufetch/issues/66
          ((pkgs.gpufetch.override {cudaSupport = is_nvidia;}).overrideAttrs (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace src/cuda/cuda.cpp \
                  --replace-fail 'mem->freq = prop.memoryClockRate * 0.001f;' \
                    'int clk = 0; cudaDeviceGetAttribute(&clk, cudaDevAttrMemoryClockRate, gpu->idx); mem->freq = clk * 0.001f;' \
                  --replace-fail 'gpu->freq = deviceProp.clockRate * 1e-3f;' \
                    'int clk = 0; cudaDeviceGetAttribute(&clk, cudaDevAttrClockRate, gpu->idx); gpu->freq = clk * 1e-3f;'
              '';
          }))
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
      nixos = {
        self',
        pkgs,
        ...
      }: {
        environment.systemPackages = [
          pkgs.telegram-desktop
          pkgs.whatsapp-electron
          self'.packages.vesktop
          pkgs.teams-for-linux
          pkgs.slack
        ];
      };
    };

    gaming = {
      includes = [(den.batteries.unfree ["steam" "steam-unwrapped" "steam-original" "steam-run"])];
      nixos = {
        self',
        pkgs,
        inputs',
        ...
      }: {
        programs.steam = {
          enable = true;
          extest.enable = true;
          gamescopeSession.enable = true;
        };
        programs.gamemode.enable = true;

        environment.systemPackages = [
          pkgs.mangohud
          pkgs.protonup-ng
          self'.packages.balatro-sync
          (pkgs.makeDesktopItem {
            name = "steam-bigpicture";
            desktopName = "Steam Big Picture";
            comment = "Steam in controller-friendly fullscreen mode";
            exec = "steam steam://open/bigpicture";
            icon = "steam";
            categories = ["Game"];
          })
        ];

        environment.sessionVariables.MANGOHUD_CONFIGFILE = "${inputs'.catppuccin.packages.mangohud}/mocha/MangoHud.conf";
      };
    };

    game-mods.nixos = {
      self',
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        pkgs.lumafly
        pkgs.r2modman
        pkgs.satisfactorymodmanager
        self'.packages.prismlauncher
        pkgs.deadlock-mod-manager
      ];
    };

    emulation.nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.eden];
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

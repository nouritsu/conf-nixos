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
        ];

        which-key'.menu.m.submenu = {
          s = {
            desc = "Spotify";
            icon = "f04c7";
            cmd = lib.getExe self'.packages.spotify;
            app-id = "^spotify$";
          };
          o = {
            desc = "OBS";
            icon = "f044b";
            cmd = lib.getExe self'.packages.obs-studio;
            app-id = "obsproject|^obs$";
          };
          v = {
            desc = "mpv";
            icon = "f1705";
            cmd = "${lib.getExe self'.packages.mpv} --player-operation-mode=pseudo-gui";
            app-id = "^mpv$";
          };
        };

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
        lib,
        ...
      }: let
        vesktop = self'.packages.novpn.wrap self'.packages.vesktop;
      in {
        environment.systemPackages = [
          pkgs.telegram-desktop
          pkgs.whatsapp-electron
          vesktop
          pkgs.teams-for-linux
          pkgs.slack
        ];

        which-key'.menu.c.submenu = {
          d = {
            desc = "Vesktop";
            icon = "f066f";
            cmd = lib.getExe vesktop;
            app-id = "vesktop";
          };
          t = {
            desc = "Telegram";
            icon = "f2c6";
            cmd = lib.getExe pkgs.telegram-desktop;
            app-id = "telegram";
          };
          w = {
            desc = "WhatsApp";
            icon = "f05a3";
            cmd = lib.getExe pkgs.whatsapp-electron;
            app-id = "whatsapp";
          };
          s = {
            desc = "Slack";
            icon = "f04b1";
            cmd = lib.getExe pkgs.slack;
            app-id = "^slack$";
          };
          m = {
            desc = "Teams";
            icon = "f02bb";
            cmd = lib.getExe pkgs.teams-for-linux;
            app-id = "teams-for-linux";
          };
        };
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

        which-key'.menu.g.submenu = {
          s = {
            desc = "Steam";
            icon = "f04d3";
            cmd = "steam";
            app-id = "^steam$";
          };
          b = {
            desc = "Big Picture";
            icon = "f0502";
            cmd = "steam steam://open/bigpicture";
          };
        };

        environment.sessionVariables.MANGOHUD_CONFIGFILE = "${inputs'.catppuccin.packages.mangohud}/mocha/MangoHud.conf";
      };
    };

    game-mods.nixos = {
      self',
      pkgs,
      lib,
      ...
    }: let
      prismlauncher = self'.packages.novpn.wrap self'.packages.prismlauncher;
    in {
      environment.systemPackages = [
        pkgs.r2modman
        prismlauncher
        pkgs.deadlock-mod-manager
      ];

      which-key'.menu.g.submenu = {
        p = {
          desc = "Prism Launcher";
          icon = "f0373";
          cmd = lib.getExe prismlauncher;
          app-id = "prismlauncher";
        };
        r = {
          desc = "r2modman";
          icon = "f0431";
          cmd = lib.getExe pkgs.r2modman;
          app-id = "r2modman";
        };
      };
    };

    emulation.nixos = {
      self',
      pkgs,
      lib,
      ...
    }: let
      eden = self'.packages.novpn.wrap pkgs.eden;
    in {
      environment.systemPackages = [eden];

      which-key'.menu.g.submenu.e = {
        desc = "Eden";
        icon = "f07e1";
        cmd = lib.getExe eden;
        app-id = "eden_emu|^eden$";
      };
    };

    proton = {
      includes = [(den.batteries.unfree ["proton-authenticator"])];
      nixos = {
        self',
        host,
        pkgs,
        lib,
        ...
      }: let
        json = (pkgs.formats.json {}).generate;

        # pi-hole first, cloudflare when away from home
        vpnSettings = json "proton-vpn-settings.json" {
          custom_dns = {
            enabled = true;
            ip_list = [
              {
                ip = "192.168.178.128";
                enabled = true;
              }
              {
                ip = "1.1.1.1";
                enabled = true;
              }
            ];
          };
        };
        vpnAppConfig = json "proton-vpn-app-config.json" {
          connect_at_app_startup = "FASTEST";
        };

        # pinned keys go over the live files; login and the rest stay GUI
        pinVpn = pkgs.writeShellApplication {
          name = "proton-vpn-pin-settings";
          runtimeInputs = [pkgs.jq pkgs.coreutils];
          text = ''
            dir=''${XDG_CONFIG_HOME:-$HOME/.config}/Proton/VPN
            mkdir -p "$dir"

            merge() {
              [ -s "$1" ] || echo '{}' > "$1"
              jq -e --slurpfile pin "$2" '. * $pin[0] == .' "$1" > /dev/null && return
              tmp=$(mktemp "$1.XXXXXX")
              if jq --slurpfile pin "$2" '. * $pin[0]' "$1" > "$tmp"; then
                mv "$tmp" "$1"
              else
                rm -f "$tmp"
              fi
            }

            merge "$dir/settings.json" ${vpnSettings}
            merge "$dir/app-config.json" ${vpnAppConfig}
          '';
        };

        # Split tunneling
        split-tunnel = self'.packages.proton-vpn-split-tunnel;
        mark = toString split-tunnel.fwmark;
        # after tailscale's rules, so tailnet addresses still go through table 52
        bypassTable = "5300";

        # steam and anything launched through novpn
        bypassApps = json "proton-vpn-bypass-apps.json" (lib.genAttrs (lib.attrNames host.users) (_: [
          "~/.local/share/Steam/"
          "~/.steam/"
          "${self'.packages.novpn}/"
        ]));

        # marked sockets get the physical routes, never the tunnel's or the kill switch's
        bypassRoutes = pkgs.writeShellApplication {
          name = "proton-vpn-bypass-routes";
          runtimeInputs = [pkgs.iproute2 pkgs.gnugrep pkgs.gnused];
          text = ''
            ip -4 rule list table ${bypassTable} | grep -q . \
              || ip -4 rule add priority ${bypassTable} fwmark ${mark} lookup ${bypassTable}

            routes=$(ip -4 route show table main | grep -v -E 'dev (proton|pvpn|ipv6leak|tailscale)' | sed 's/ linkdown//' || true)
            ip -4 route flush table ${bypassTable} 2> /dev/null || true
            while read -r route; do
              # shellcheck disable=SC2086
              [ -z "$route" ] || ip -4 route add $route table ${bypassTable} || echo "skipped: $route" >&2
            done <<< "$routes"
          '';
        };
      in {
        environment.systemPackages = [
          pkgs.proton-authenticator
          pkgs.protonmail-desktop
          pkgs.proton-pass
          pkgs.proton-vpn
          self'.packages.novpn
        ];

        # pi-hole is unreachable away from home; fall through to the next server fast
        networking.resolvconf.extraOptions = ["timeout:1"];

        systemd.services.proton-vpn-split-tunneling = {
          description = "Proton VPN split tunneling";
          wantedBy = ["multi-user.target"];
          # bcc builds its bpf against the running kernel's kheaders module
          path = [pkgs.kmod pkgs.gnutar pkgs.xz];
          # a kernel bcc can't build against fails every start; stop retrying
          startLimitBurst = 3;
          startLimitIntervalSec = 120;
          serviceConfig = {
            ExecStartPre = "-${lib.getExe bypassRoutes}";
            ExecStart = "${lib.getExe split-tunnel} ${mark} ${bypassApps}";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        networking.networkmanager.dispatcherScripts = [
          {
            source = lib.getExe bypassRoutes;
            type = "basic";
          }
        ];

        # novpn in front of the line, or of the last command if empty
        programs.fish.interactiveShellInit = ''
          bind alt-v 'fish_commandline_prepend novpn'
        '';

        systemd.user.services.proton-vpn = {
          description = "Proton VPN";
          wantedBy = ["graphical-session.target"];
          partOf = ["graphical-session.target"];
          after = ["graphical-session.target"];
          serviceConfig = {
            ExecStartPre = "-${lib.getExe pinVpn}";
            # it checks for a tray only at launch
            ExecStart = "${lib.getExe self'.packages.wait-for-tray} ${lib.getExe pkgs.proton-vpn} --start-minimized";
            Restart = "on-failure";
            Slice = "app.slice";
          };
        };

        which-key'.menu.p.submenu = {
          m = {
            desc = "Mail";
            icon = "f01ee";
            cmd = lib.getExe pkgs.protonmail-desktop;
            app-id = "proton.?mail";
          };
          p = {
            desc = "Pass";
            icon = "f030b";
            cmd = lib.getExe pkgs.proton-pass;
            app-id = "proton.?pass";
          };
          v = {
            desc = "VPN";
            icon = "f0582";
            cmd = lib.getExe pkgs.proton-vpn;
            app-id = "protonvpn|proton.vpn";
          };
          a = {
            desc = "Authenticator";
            icon = "f09af";
            cmd = lib.getExe pkgs.proton-authenticator;
            app-id = "proton.?authenticator";
          };
        };
      };
    };
  };
}

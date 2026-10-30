{inputs, ...}: {
  # on every host, so any aspect can add entries
  den.default.nixos = {lib, ...}: {
    # binaries the privacy indicator never shows
    options.privacyApps'.ignore = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  den.aspects.dux = {
    nixos = {
      config,
      pkgs,
      lib,
      inputs',
      self',
      ...
    }: let
      settings = (pkgs.formats.json {}).generate "dux-settings.json" (
        lib.pipe (lib.importJSON ./dux-settings.json) config.dux'.settingsOverrides
      );

      # every installed plugin is switched on, plus its pinned settings
      pluginSettings = let
        pinned = lib.importJSON ./dux-plugin-settings.json;
        installed = lib.filterAttrs (_: p: p.enable) config.programs.dux-shell.plugins;
      in
        (pkgs.formats.json {}).generate "dux-plugin-settings.json"
        (lib.recursiveUpdate
          (lib.mapAttrs (id: _: {enabled = true;} // pinned.${id} or {}) installed)
          {privacyApps.ignore = config.privacyApps'.ignore;});

      # which-key entries for privacyApps' ipc
      privacyEntries = action: icons: {
        c = {
          desc = "Camera";
          icon = icons.camera;
          cmd = "dms ipc call privacyApps ${action} camera";
        };
        m = {
          desc = "Mic";
          icon = icons.mic;
          cmd = "dms ipc call privacyApps ${action} mic";
        };
        s = {
          desc = "Stream";
          icon = icons.screen;
          cmd = "dms ipc call privacyApps ${action} screen";
        };
        a = {
          desc = "All";
          icon = icons.all;
          cmd = "dms ipc call privacyApps ${action} all";
        };
      };

      clipboard = (pkgs.formats.json {}).generate "dux-clipboard.json" {
        maxHistory = -1;
        maxEntrySize = 52428800;
        maxPinned = 25;
        autoClearDays = 90;
        clearAtStartup = false;
        disabled = false;
      };

      # theme schedule off, night light on its schedule
      session = (pkgs.formats.json {}).generate "dux-session.json" {
        themeModeAutoEnabled = false;
        nightModeEnabled = true;
        nightModeAutoEnabled = true;
      };

      # pinned keys go over the live files; tokens, history and other state stay
      pinSettings = pkgs.writeShellApplication {
        name = "dux-pin-settings";
        runtimeInputs = [pkgs.jq pkgs.coreutils];
        text = ''
          dir=''${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell
          state=''${XDG_STATE_HOME:-$HOME/.local/state}/DankMaterialShell
          mkdir -p "$dir" "$state"

          merge() {
            [ -f "$1" ] || echo '{}' > "$1"
            jq -e --slurpfile pin "$2" '. * $pin[0] == .' "$1" > /dev/null && return
            tmp=$(mktemp "$1.XXXXXX")
            if jq --slurpfile pin "$2" '. * $pin[0]' "$1" > "$tmp"; then
              mv "$tmp" "$1"
            else
              rm -f "$tmp"
            fi
          }

          merge "$dir/plugin_settings.json" ${pluginSettings}
          merge "$dir/clsettings.json" ${clipboard}
          merge "$state/session.json" ${session}
        '';
      };
    in {
      imports = [
        inputs.dux-plugin-registry.nixosModules.default
        {
          # per-host edits to the pinned settings, applied in order
          options.dux'.settingsOverrides = lib.mkOption {
            type = lib.types.listOf (lib.types.functionTo lib.types.attrs);
            default = [];
          };
        }
      ];

      environment.systemPackages = [
        pkgs.wl-clipboard-rs
        pkgs.xournalpp
        pkgs.dux-search
        pkgs.wl-mirror

        # Plugin deps
        pkgs.translate-shell # dankTranslate: trans
        (pkgs.tesseract.override {enableLanguages = ["eng" "deu"];}) # ocrScanner
        pkgs.file # ocrScanner: clipboard scans are gated on `file --mime-type`
        pkgs.librsvg # ocrScanner: rsvg-convert for dropped SVGs
        pkgs.libnotify # notify-send: ipIndicator IP changes, gameControllerBattery, dankPomodoroTimer
        pkgs.glib # gdbus: dankKDEConnect image sharing
      ];

      # gameControllerBattery, batteryPlus
      services.upower.enable = true;

      # the bar's media visualiser records desktop audio
      privacyApps'.ignore = ["cava"];

      # screenRecorderYS
      programs.gpu-screen-recorder.enable = true;

      # settings.json is read-only; GUI changes come back through Dux's
      # copy-JSON button into dux-settings.json
      systemd.user.tmpfiles.rules = [
        "L+ %h/.config/DankMaterialShell/settings.json - - - - ${settings}"
        "L+ %h/.config/DankMaterialShell/themes/catppuccin/theme.json - - - - ${inputs.dux-plugin-registry}/themes/catppuccin/theme.json"
      ];

      # dux only reads plugin settings and session at start and saves its own copy over later edits
      systemd.user.services.dms.serviceConfig.ExecStartPre = "-${lib.getExe pinSettings}";

      # dux keeps watching the old link target; restart it when a pin changes
      system.userActivationScripts.dux-settings = {
        deps = ["tmpfiles"];
        text = ''
          stamp=''${XDG_STATE_HOME:-$HOME/.local/state}/dux-settings-pin
          if [ "$(cat "$stamp" 2>/dev/null)" != "${settings} ${pinSettings}" ]; then
            mkdir -p "$(dirname "$stamp")"
            echo "${settings} ${pinSettings}" > "$stamp"
            ${pkgs.systemd}/bin/systemctl --user --no-block try-restart dms.service || true
          fi
        '';
      };

      programs.kdeconnect = {
        enable = true;
        package = self'.packages.kdeconnect;
      };

      # gnome's RemoteDesktop and InputCapture need mutter, which niri lacks;
      # both backends allow-list kdeconnect as a caller
      xdg.portal = {
        extraPortals = [
          self'.packages.hypr-kdeconnect-fix
          self'.packages.xdg-desktop-portal-layercapture
        ];
        config.niri = {
          "org.freedesktop.impl.portal.RemoteDesktop" = ["hypr-kdeconnect"];
          "org.freedesktop.impl.portal.InputCapture" = ["layercapture"];
        };
      };

      which-key'.menu.t.submenu = {
        c = {
          desc = "Colour picker";
          icon = "f020a";
          cmd = "dms color pick -a";
        };
        W = {
          desc = "Wallpaper carousel";
          icon = "f0e09";
          cmd = "dms ipc call wallpaperCarousel toggle";
        };
        k = {
          desc = "KDE Connect";
          icon = "f373";
          cmd = "kdeconnect-app";
          app-id = "kdeconnect";
        };
        n = {
          desc = "Dux notepad";
          icon = "f039e";
          cmd = "dms ipc call notepad open";
        };
      };

      # for the focused window's app
      which-key'.menu.b.submenu = privacyEntries "block" {
        camera = "f1737";
        mic = "f036d";
        screen = "f078a";
        all = "f00ad";
      };
      which-key'.menu.B.submenu = privacyEntries "unblock" {
        camera = "f05a0";
        mic = "f036c";
        screen = "f0118";
        all = "f012d";
      };

      # Dux's power-profile switcher and cpu.balanced need it
      services.power-profiles-daemon.enable = true;

      programs.dux-shell = {
        enable = true;
        package = inputs'.dux.packages.default;

        plugins = {
          dankKDEConnect.enable = true;
          calculator.enable = true;
          emojiLauncher.enable = true;
          commandRunner.enable = true;
          displayMirror.enable = true;
          webSearch.enable = true;
          sshConnections.enable = true;
          airQuality.enable = true;
          dockerManager.enable = true;
          dankLauncherKeys.enable = true;
          wallpaperCarousel.enable = true;
          handMirror.enable = true;
          recentFiles.enable = true;
          dankTranslate.enable = true;
          systemMonitorPlus.enable = true;
          nixPackageRunner.enable = true;
          ocrScanner.enable = true;
          dankPomodoroTimer.enable = true;
          takeABreak.enable = true;
          simpleAudioControl.enable = true;
          gameControllerBattery.enable = true;
          batteryPlus.enable = true;
          screenRecorderYS.enable = true;
          windowFx.enable = true;

          # local: the focused window's width and height as a % of the screen
          columnWidth = {
            enable = true;
            src = self'.packages.dux-column-width;
          };

          # local: the privacy indicator, plus a popout of the apps behind it
          privacyApps = {
            enable = true;
            src = self'.packages.dux-privacy-apps;
          };

          # patched: mkForce over the registry's src

          # script path assumed the per-user plugin dir
          claudeCodeUsage = {
            enable = true;
            src = lib.mkForce (pkgs.applyPatches {
              name = "dux-plugin-claudeCodeUsage";
              src = inputs'.dux-plugin-registry.packages.claudeCodeUsage;
              postPatch = ''
                substituteInPlace ClaudeCodeUsageWidget.qml --replace-fail \
                  'PluginService.pluginDirectory + "/claudeCodeUsage/get-claude-usage"' \
                  'PluginService.getPluginPath("claudeCodeUsage") + "/get-claude-usage"'
              '';
            });
          };

          # any interface named like a vpn counts, so an idle tailscale0 always
          # shows; only count it when internet traffic is routed through it
          ipIndicator = {
            enable = true;
            src = lib.mkForce (pkgs.applyPatches {
              name = "dux-plugin-ipIndicator";
              src = inputs'.dux-plugin-registry.packages.ipIndicator;
              postPatch = ''
                substituteInPlace IPIndicatorWidget.qml \
                  --replace-fail "ls /sys/class/net | grep -E '^(" "ip route get 1.1.1.1 | grep -oE 'dev (" \
                  --replace-fail "cscotun)' | head -1" "cscotun)[^ ]*' | cut -c5- | head -1"
              '';
            });
          };

          # dux's clipboard dies with a dux restart and offers the png path,
          # deleted 10 s later; wl-copy holds the image bytes in its own process
          screenshotPlus = {
            enable = true;
            src = lib.mkForce (pkgs.applyPatches {
              name = "dux-plugin-screenshotPlus";
              src = inputs'.dux-plugin-registry.packages.screenshotPlus;
              patches = [./screenshot-plus-wl-copy.patch];
            });
          };
        };
      };
    };

    # the token is a pc-only sops secret
    provides.home-assistant.nixos = {
      pkgs,
      lib,
      inputs',
      ...
    }: {
      environment.systemPackages = [pkgs.qt6.qtwebsockets];

      # a failed connect ends in Error, never Closed, so reconnect() waits
      # forever and the widget stays on REST; re-arm once nothing is pending
      programs.dux-shell.plugins.homeAssistantMonitor = {
        enable = true;
        src = lib.mkForce (pkgs.applyPatches {
          name = "dux-plugin-homeAssistantMonitor";
          src = inputs'.dux-plugin-registry.packages.homeAssistantMonitor;
          postPatch = ''
            substituteInPlace services/WebSocketClient.qml \
              --replace-fail '_reopenOnClosed = true;' '_reopenOnClosed = true; reopenFallback.restart();' \
              --replace-fail 'function sendTextMessage(msg) {' 'Timer { id: reopenFallback; interval: 3500; onTriggered: if (socket.status === WebSocket.Error) root._reopenIfPending() }

                function sendTextMessage(msg) {'
          '';
        });
      };
    };

    # dcal colours a single-file calendar from its VCALENDAR and names it after
    # the file, so the feeds are mirrored with our colour written in
    provides.calendar.nixos = {
      config,
      host,
      pkgs,
      lib,
      ...
    }: let
      owner = lib.head (lib.attrNames host.users);

      # .ics on the server, calendar name, catppuccin mocha colour, token
      feeds = [
        {
          feed = "lectures";
          name = "CampusNet · Lectures";
          color = "#cba6f7";
          token = "vps";
        }
        {
          feed = "tutorials";
          name = "CampusNet · Tutorials";
          color = "#a6e3a1";
          token = "vps";
        }
        {
          feed = "exams";
          name = "CampusNet · Exams";
          color = "#f38ba8";
          token = "vps";
        }
        {
          feed = "other";
          name = "CampusNet · Other";
          color = "#89b4fa";
          token = "vps";
        }
        {
          feed = "birthdays";
          name = "Birthdays";
          color = "#fab387";
          token = "homelab";
        }
      ];

      # calendar-level colours out, ours in; folded lines go with their property
      recolour = pkgs.writeText "calsync-recolour.awk" ''
        {
          line = $0
          sub(/\r$/, "", line)
        }
        drop && line ~ /^[ \t]/ { next }
        { drop = 0 }
        line == "BEGIN:VCALENDAR" {
          print
          printf "X-APPLE-CALENDAR-COLOR:%s\r\n", color
          header = 1
          next
        }
        header && line ~ /^BEGIN:/ { header = 0 }
        header && toupper(line) ~ /^(COLOR|X-APPLE-CALENDAR-COLOR)[;:]/ {
          drop = 1
          next
        }
        { print }
      '';

      calsync = pkgs.writeShellApplication {
        name = "calsync";
        runtimeInputs = [pkgs.curl pkgs.gawk pkgs.jq pkgs.coreutils pkgs.dux-calendar];
        text = ''
          shopt -s nullglob
          dir=''${XDG_DATA_HOME:-$HOME/.local/share}/calsync
          mkdir -p "$dir"

          # temp names without .ics, or dcal lists them as calendars
          fetch() {
            local feed=$1 name=$2 color=$3 tmp
            tmp=$(mktemp "$dir/.$feed.XXXXXX")
            if curl -fsSL --max-time 60 -o "$tmp" "https://cal.nouritsu.com/$(< "$4")/$feed.ics" \
              && [ "$(head -c 15 "$tmp")" = BEGIN:VCALENDAR ]; then
              awk -v color="$color" -f ${recolour} "$tmp" > "$tmp.new"
              mv "$tmp.new" "$dir/$name.ics"
            else
              echo "$feed: fetch failed, keeping the last copy" >&2
            fi
            rm -f "$tmp" "$tmp.new"
          }

          ${lib.concatMapStrings (f: ''
              fetch ${lib.escapeShellArgs [f.feed f.name f.color config.sops.secrets."calsync/${f.token}-token".path]}
            '')
            feeds}
          # feeds dropped from the list
          for f in "$dir"/*.ics; do
            case ''${f##*/} in
              ${lib.concatMapStringsSep " | " (f: lib.escapeShellArg "${f.name}.ics") feeds}) ;;
              *) rm -f "$f" ;;
            esac
          done

          # dcal seeds a default calendar into an empty dir, so wait for a feed
          files=("$dir"/*.ics)
          if [ ''${#files[@]} -gt 0 ]; then
            if ! dcal account list --json | jq -e 'any(.[]; .id == "local:calsync")' > /dev/null; then
              dcal account add local "$dir" --name Subscriptions > /dev/null
            fi
            dcal sync local:calsync > /dev/null
          fi
        '';
      };
    in {
      sops.secrets = lib.genAttrs ["calsync/vps-token" "calsync/homelab-token"] (_: {
        sopsFile = ../secrets/shared.yaml;
        inherit owner;
      });

      environment.systemPackages = [pkgs.dux-calendar];

      # dux's calendar reads events from the dcal daemon
      systemd.packages = [pkgs.dux-calendar];
      systemd.user.services.dcal = {
        wantedBy = ["graphical-session.target"];
        # quickshell for its window comes from the session PATH
        path = lib.mkForce [];
      };

      systemd.user.services.calsync = {
        description = "Mirror the calendar feeds for dcal";
        after = ["dcal.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe calsync;
        };
      };
      systemd.user.timers.calsync = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnStartupSec = "1min";
          OnUnitActiveSec = "30min";
        };
      };
    };

    provides.battery.nixos.programs.dux-shell.plugins.batteryOSD.enable = true;

    # expects its go cli hand-built inside the per-user plugin dir
    provides.razer.nixos = {
      pkgs,
      lib,
      inputs',
      self',
      ...
    }: let
      src = inputs'.dux-plugin-registry.packages.dankRazer;
      dankrazer = self'.packages.dankrazer;
    in {
      programs.dux-shell.plugins.dankRazer = {
        enable = true;
        src = lib.mkForce (pkgs.applyPatches {
          name = "dux-plugin-dankRazer";
          inherit src;
          postPatch = ''
            substituteInPlace DankRazerWidget.qml --replace-fail \
              'pluginService.pluginDirectory + "/dankRazer/dankrazer-cli/dankrazer"' \
              '"${lib.getExe dankrazer}"'
            # string/toggle settings have no leftIcon, so the page fails to load
            substituteInPlace DankRazerSettings.qml \
              --replace-fail 'leftIcon: "palette"' "" \
              --replace-fail 'leftIcon: "touch_app"' "" \
              --replace-fail 'leftIcon: "sync"' "" \
              --replace-fail 'leftIcon: "bedtime"' ""
          '';
        });
      };
    };

    # hardcodes VPC2004:00 and errors on every start without it
    provides.ideapad.nixos = {lib, ...}: {
      programs.dux-shell.plugins.dmsLenovoBatterySettings.enable = true;

      # laptop only: Bar 2, right after batteryPlus
      dux'.settingsOverrides = [
        (settings: let
          widget = {
            id = "dmsLenovoBatterySettings";
            enabled = true;
          };
          place = widgets:
            lib.concatMap (w: [w] ++ lib.optional (w.id == "batteryPlus") widget)
            (builtins.filter (w: w.id != widget.id) widgets);
        in
          settings
          // {
            barConfigs = map (bar:
              if bar.id == "bar1791747327469"
              then bar // {leftWidgets = place bar.leftWidgets;}
              else bar)
            settings.barConfigs;
          })
      ];
    };

    provides.tailscale.nixos = {
      config,
      pkgs,
      lib,
      inputs',
      ...
    }: let
      tailscale = lib.getExe' config.services.tailscale.package "tailscale";
    in {
      programs.dux-shell.plugins.dankscale = {
        enable = true;

        # pkexec execs the resolved path on a bare PATH, which turns tailscale
        # into tailscaled and breaks uutils' multicall env/timeout
        src = lib.mkForce (pkgs.applyPatches {
          name = "dux-plugin-dankscale";
          src = inputs'.dux-plugin-registry.packages.dankscale;
          postPatch = ''
            substituteInPlace services/TailscaleService.qml \
              --replace-fail '"pkexec", "tailscale"' '"pkexec", "${pkgs.coreutils}/bin/env", "${tailscale}"' \
              --replace-fail '"pkexec", "timeout"' '"pkexec", "${pkgs.coreutils}/bin/timeout"' \
              --replace-fail '"tailscale", "login"' '"${tailscale}", "login"'
          '';
        });
      };
    };
  };
}

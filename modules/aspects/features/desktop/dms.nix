{inputs, ...}: {
  den.aspects.dms = {
    nixos = {
      config,
      pkgs,
      lib,
      inputs',
      self',
      ...
    }: let
      tabctlHost = pkgs.writeText "tabctl_mediator.json" (builtins.toJSON {
        name = "tabctl_mediator";
        description = "TabCtl native messaging host";
        path = "/run/current-system/sw/bin/tabctl-mediator";
        type = "stdio";
        allowed_origins = ["chrome-extension://baomblllgemcgbignhpbipgiofmjdhpn/"];
      });

      settings = (pkgs.formats.json {}).generate "dms-settings.json" (
        lib.pipe (lib.importJSON ./dms-settings.json) config.dms'.settingsOverrides
      );
    in {
      imports = [
        inputs.dms-plugin-registry.nixosModules.default
        {
          # per-host edits to the pinned settings, applied in order
          options.dms'.settingsOverrides = lib.mkOption {
            type = lib.types.listOf (lib.types.functionTo lib.types.attrs);
            default = [];
          };
        }
      ];

      environment.systemPackages = [
        pkgs.wl-clipboard-rs
        pkgs.xournalpp
        pkgs.dsearch
        pkgs.wl-mirror

        # Plugin deps
        pkgs.translate-shell # dankTranslate: trans
        (pkgs.tesseract.override {enableLanguages = ["eng" "deu"];}) # ocrScanner
        pkgs.file # ocrScanner: clipboard scans are gated on `file --mime-type`
        pkgs.librsvg # ocrScanner: rsvg-convert for dropped SVGs
        pkgs.libnotify # notify-send: ipIndicator IP changes, gameControllerBattery, dankPomodoroTimer
        pkgs.glib # gdbus: dankKDEConnect image sharing
        self'.packages.tabctl # tabsLauncher
      ];

      # gameControllerBattery, batteryPlus
      services.upower.enable = true;

      # screenRecorderYS
      programs.gpu-screen-recorder.enable = true;

      # tabsLauncher: brave reaches tabctl through its extension's native host
      programs.chromium.extensions = ["baomblllgemcgbignhpbipgiofmjdhpn;https://clients2.google.com/service/update2/crx"];

      # settings.json is read-only; GUI changes come back through DMS's
      # copy-JSON button into dms-settings.json
      systemd.user.tmpfiles.rules = [
        "L+ %h/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts/tabctl_mediator.json - - - - ${tabctlHost}"
        "L+ %h/.config/DankMaterialShell/settings.json - - - - ${settings}"
        "L+ %h/.config/DankMaterialShell/themes/catppuccin/theme.json - - - - ${inputs.dms-plugin-registry}/themes/catppuccin/theme.json"
      ];

      # dms keeps watching the old link target; restart it when the pin changes
      system.userActivationScripts.dms-settings = {
        deps = ["tmpfiles"];
        text = ''
          stamp=''${XDG_STATE_HOME:-$HOME/.local/state}/dms-settings-pin
          if [ "$(cat "$stamp" 2>/dev/null)" != "${settings}" ]; then
            mkdir -p "$(dirname "$stamp")"
            echo "${settings}" > "$stamp"
            ${pkgs.systemd}/bin/systemctl --user --no-block try-restart dms.service || true
          fi
        '';
      };

      programs.kdeconnect = {
        enable = true;
      };

      # DMS's power-profile switcher and cpu.balanced need it
      services.power-profiles-daemon.enable = true;

      programs.dms-shell = {
        enable = true;
        package = inputs'.dms.packages.default;

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
          screenshotPlus.enable = true;
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
          tabsLauncher.enable = true;
          windowFx.enable = true;

          # patched: mkForce over the registry's src

          # script path assumed the per-user plugin dir
          claudeCodeUsage = {
            enable = true;
            src = lib.mkForce (pkgs.applyPatches {
              name = "dms-plugin-claudeCodeUsage";
              src = inputs'.dms-plugin-registry.packages.claudeCodeUsage;
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
              name = "dms-plugin-ipIndicator";
              src = inputs'.dms-plugin-registry.packages.ipIndicator;
              postPatch = ''
                substituteInPlace IPIndicatorWidget.qml \
                  --replace-fail "ls /sys/class/net | grep -E '^(" "ip route get 1.1.1.1 | grep -oE 'dev (" \
                  --replace-fail "cscotun)' | head -1" "cscotun)[^ ]*' | cut -c5- | head -1"
              '';
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

      environment.sessionVariables = {
        QML2_IMPORT_PATH = "${pkgs.qt6.qtwebsockets}/${pkgs.qt6.qtbase.qtQmlPrefix}";
        QML_IMPORT_PATH = "${pkgs.qt6.qtwebsockets}/${pkgs.qt6.qtbase.qtQmlPrefix}";
      };

      # a failed connect ends in Error, never Closed, so reconnect() waits
      # forever and the widget stays on REST; re-arm once nothing is pending
      programs.dms-shell.plugins.homeAssistantMonitor = {
        enable = true;
        src = lib.mkForce (pkgs.applyPatches {
          name = "dms-plugin-homeAssistantMonitor";
          src = inputs'.dms-plugin-registry.packages.homeAssistantMonitor;
          postPatch = ''
            substituteInPlace services/WebSocketClient.qml \
              --replace-fail '_reopenOnClosed = true;' '_reopenOnClosed = true; reopenFallback.restart();' \
              --replace-fail 'function sendTextMessage(msg) {' 'Timer { id: reopenFallback; interval: 3500; onTriggered: if (socket.status === WebSocket.Error) root._reopenIfPending() }

                function sendTextMessage(msg) {'
          '';
        });
      };
    };

    provides.battery.nixos.programs.dms-shell.plugins.batteryOSD.enable = true;

    # expects its go cli hand-built inside the per-user plugin dir
    provides.razer.nixos = {
      pkgs,
      lib,
      inputs',
      ...
    }: let
      src = inputs'.dms-plugin-registry.packages.dankRazer;
      dankrazer = pkgs.buildGoModule {
        pname = "dankrazer";
        inherit (src) version;
        src = "${src}/dankrazer-cli";
        vendorHash = "sha256-+oHslT8yKWaToq2zmVJ+NVowPfRGR6R6ajapFywmgo8=";
        subPackages = ["cmd/dankrazer"];
        meta.mainProgram = "dankrazer";
      };
    in {
      programs.dms-shell.plugins.dankRazer = {
        enable = true;
        src = lib.mkForce (pkgs.applyPatches {
          name = "dms-plugin-dankRazer";
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
      programs.dms-shell.plugins.dmsLenovoBatterySettings.enable = true;

      # laptop only: Bar 2, right after batteryPlus
      dms'.settingsOverrides = [
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
      programs.dms-shell.plugins.dankscale = {
        enable = true;

        # pkexec execs the resolved path on a bare PATH, which turns tailscale
        # into tailscaled and breaks uutils' multicall env/timeout
        src = lib.mkForce (pkgs.applyPatches {
          name = "dms-plugin-dankscale";
          src = inputs'.dms-plugin-registry.packages.dankscale;
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

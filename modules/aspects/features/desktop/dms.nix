{inputs, ...}: {
  den.aspects.dms = {
    nixos = {
      pkgs,
      lib,
      inputs',
      ...
    }: {
      imports = [
        inputs.dms-plugin-registry.nixosModules.default
      ];

      environment.systemPackages = [
        pkgs.wl-clipboard-rs
        pkgs.qt6.qtwebsockets
        pkgs.xournalpp
        pkgs.dsearch
        pkgs.wl-mirror

        # Plugin deps
        pkgs.translate-shell # dankTranslate: trans
        (pkgs.tesseract.override {enableLanguages = ["eng" "deu"];}) # ocrScanner
        pkgs.file # ocrScanner: clipboard scans are gated on `file --mime-type`
        pkgs.librsvg # ocrScanner: rsvg-convert for dropped SVGs
        pkgs.ddcutil # displayManager: DDC/CI brightness and contrast
        pkgs.libnotify # notify-send: smartTimer alarms, ipIndicator IP changes
        pkgs.glib # gdbus: smartTimer closes its notifications; gio for About links
      ];

      environment.sessionVariables = {
        QML2_IMPORT_PATH = "${pkgs.qt6.qtwebsockets}/${pkgs.qt6.qtbase.qtQmlPrefix}";
        QML_IMPORT_PATH = "${pkgs.qt6.qtwebsockets}/${pkgs.qt6.qtbase.qtQmlPrefix}";
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
          displayOutput.enable = true;
          airQuality.enable = true;
          dockerManager.enable = true;
          dankActions.enable = true;
          dankLauncherKeys.enable = true;
          wallpaperCarousel.enable = true;
          displayManager.enable = true;
          handMirror.enable = true;
          hiddenBar.enable = true;
          recentFiles.enable = true;
          screenshotPlus.enable = true;
          dankTranslate.enable = true;
          systemMonitorPlus.enable = true;
          nixPackageRunner.enable = true;
          formatColorPicker.enable = true;
          ocrScanner.enable = true;
          orbitBluetooth.enable = true;

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

          # a failed connect ends in Error, never Closed, so reconnect() waits
          # forever and the widget stays on REST; re-arm once nothing is pending
          homeAssistantMonitor = {
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

          # sounds hardcoded to /usr/share/sounds
          smartTimer = {
            enable = true;
            src = lib.mkForce (pkgs.applyPatches {
              name = "dms-plugin-smartTimer";
              src = inputs'.dms-plugin-registry.packages.smartTimer;
              postPatch = ''
                substituteInPlace TimerDaemon.qml TimerSettings.qml \
                  --replace-fail /usr/share/sounds /run/current-system/sw/share/sounds
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

    provides.battery.nixos.programs.dms-shell.plugins.batteryOSD.enable = true;

    # hardcodes VPC2004:00 and errors on every start without it
    provides.ideapad.nixos.programs.dms-shell.plugins.dmsLenovoBatterySettings.enable = true;

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

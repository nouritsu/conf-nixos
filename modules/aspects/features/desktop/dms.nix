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

        # Plugin runtime deps. The dms service runs on the session PATH, so
        # plugins find these by bare name.
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

      # DMS's power-profile switcher talks to this daemon over D-Bus, and
      # cpu.balanced Requires it. nixpkgs' dms-shell module enabled it by
      # default until the 2026-09-26 nixpkgs; since then only hosts with the
      # power aspect had it, and pc silently lost it.
      services.power-profiles-daemon.enable = true;

      programs.dms-shell = {
        enable = true;
        package = inputs'.dms.packages.default;

        plugins = {
          homeAssistantMonitor.enable = true;
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
          ipIndicator.enable = true;
          hiddenBar.enable = true;
          recentFiles.enable = true;
          screenshotPlus.enable = true;
          dankTranslate.enable = true;
          systemMonitorPlus.enable = true;
          nixPackageRunner.enable = true;
          formatColorPicker.enable = true;
          ocrScanner.enable = true;
          orbitBluetooth.enable = true;

          # The two below assume a distro layout, so they get a patched src.
          # The registry module sets `src` at normal priority, hence mkForce.

          # The widget builds its script path from DMS's per-user plugin dir
          # (~/.config/DankMaterialShell/plugins), which is empty when plugins
          # come from /etc/xdg; ask PluginService where this one lives.
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

          # Sands: the alarm and tick defaults and the sound picker all look in
          # /usr/share/sounds.
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

          # dankBatteryAlerts and powerOptions are gone from the registry, and
          # enabling a name it no longer defines leaves `.src` undefined, which is
          # an eval error rather than a no-op. Both were delisted because DMS
          # absorbed them: low/critical battery notifications are now
          # Settings -> Battery -> Alerts (batteryNotifyLow, batteryNotifyCritical),
          # and the launcher grows a built-in `dms_power` provider covering lock,
          # logout, suspend, hibernate, reboot, soft reboot and poweroff.
        };
      };
    };

    # Charger plug/unplug and low-battery OSD, fed by UPower.
    provides.battery.nixos.programs.dms-shell.plugins.batteryOSD.enable = true;

    # IdeaPad conservation mode, toggled through pkexec. It hard-codes
    # /sys/bus/platform/devices/VPC2004:00 and toasts an error on every DMS
    # start where that device is missing.
    provides.ideapad.nixos.programs.dms-shell.plugins.dmsLenovoBatterySettings.enable = true;
  };
}

{inputs, ...}: {
  flake.nixosModules.app-dms = {pkgs, ...}: {
    my.hmModules = ["app-dms"];

    imports = [
      inputs.dms-plugin-registry.modules.default
    ];

    environment.systemPackages = [
      pkgs.wl-clipboard-rs
      pkgs.qt6.qtwebsockets
      pkgs.valent
      pkgs.xournalpp
    ];

    programs.kdeconnect = {
      enable = true;
      package = pkgs.valent;
    };

    programs.dms-shell = {
      enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

      plugins = {
        homeAssistantMonitor.enable = true;
        dankKDEConnect.enable = true;
        calculator.enable = true;
        emojiLauncher.enable = true;
        commandRunner.enable = true;
        webSearch.enable = true;
        sshConnections.enable = true;
        displayOutput.enable = true;
        airQuality.enable = true;
        worldClockMulti.enable = true;
        musicLyrics.enable = true;
        nixMonitor.enable = true;
        sshMonitor.enable = true;
        dockerManager.enable = true;
        dankActions.enable = true;
        dankBitwarden.enable = true;
        dankPomodoroTimer.enable = true;
        dankBatteryAlerts.enable = true;
        dankLauncherKeys.enable = true;
        powerOptions.enable = true;
        dankDesktopWeather.enable = true;
        hyprlandSubmap.enable = true;
        appShortcut.enable = true;
      };
    };
  };

  flake.homeModules.app-dms = {...}: {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        # "dms run"
        "valent --gapplication-service"
      ];

      source = [
        "~/.config/hypr/dms/colors.conf"
        "~/.config/hypr/dms/layout.conf"
        "~/.config/hypr/dms/outputs.conf"
      ];

      bindr = [
        "SUPER, SUPER_L, exec, dms ipc call spotlight toggle"
      ];

      bind = [
        "SUPER, Space, exec, dms ipc call notifications toggle"
        "SUPER, V, exec, dms ipc call clipboard toggle"
        "SUPER, I, exec, dms ipc call settings focusOrToggle"
        "SUPER, C, exec, dms ipc call control-center toggle"
        "SUPER, Escape, exec, dms ipc call powermenu toggle"
        "SUPERSHIFT, Escape, exec, dms ipc call processlist focusOrToggle"
        "SUPERALT, W, exec, dms ipc call dankdash wallpaper"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, dms ipc call audio increment 3"
        ",XF86AudioLowerVolume, exec, dms ipc call audio decrement 3"
        ",XF86MonBrightnessUp, exec, dms ipc call brightness increment 5"
        ",XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5"
      ];

      bindl = [
        ",XF86AudioMute, exec, dms ipc call audio mute"
      ];

      layerrule = [
        "no_anim on, match:namespace dms"
        "no_anim on, match:namespace dms:spotlight"
        "no_anim on, match:namespace dms:clipboard"
        "no_anim on, match:namespace dms:notification-center-modal"
        "no_anim on, match:namespace dms:power-menu"
      ];

      windowrule = [
        "float on, match:class org\\.quickshell"
      ];
    };
  };
}

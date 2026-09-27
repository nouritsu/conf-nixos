{inputs, ...}: {
  den.aspects.dms.nixos = {
    pkgs,
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
    ];

    environment.sessionVariables = {
      QML2_IMPORT_PATH = "${pkgs.qt6.qtwebsockets}/${pkgs.qt6.qtbase.qtQmlPrefix}";
      QML_IMPORT_PATH = "${pkgs.qt6.qtwebsockets}/${pkgs.qt6.qtbase.qtQmlPrefix}";
    };

    programs.kdeconnect = {
      enable = true;
    };

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
}

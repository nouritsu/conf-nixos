{inputs, ...}: {
  flake.nixosModules.app-dms = {pkgs, ...}: {
    imports = [
      inputs.dms-plugin-registry.modules.default
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
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
        dankBatteryAlerts.enable = true;
        dankLauncherKeys.enable = true;
        powerOptions.enable = true;
      };
    };
  };
}

{
  pkgs,
  inputs,
  ...
}: {
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
}

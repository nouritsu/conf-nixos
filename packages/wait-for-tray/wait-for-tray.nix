{
  perSystem = {pkgs, ...}: {
    # runs the command once a tray (Dux's StatusNotifier host) is up, at most 30 s later;
    # apps that find no tray at launch never show their icon
    packages.wait-for-tray = pkgs.writeShellApplication {
      name = "wait-for-tray";
      runtimeInputs = [pkgs.systemd pkgs.coreutils];
      text = ''
        for _ in $(seq 150); do
          host=$(busctl --user get-property org.kde.StatusNotifierWatcher /StatusNotifierWatcher \
            org.kde.StatusNotifierWatcher IsStatusNotifierHostRegistered 2>/dev/null || true)
          [ "$host" = "b true" ] && break
          sleep 0.2
        done
        exec "$@"
      '';
    };
  };
}

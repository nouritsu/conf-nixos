{usrconf, ...}: {
  hardware.openrazer = {
    enable = true;
    users = [usrconf.user.alias];
    syncEffectsEnabled = true;
    keyStatistics = true;
  };
}

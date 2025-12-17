{usrconf, ...}: {
  hardware.openrazer = {
    enable = true;
    users = [usrconf.user.alias];
    syncEffectsEnabled = true;
    keyStatistics = true;
  };
  users.users.${usrconf.user.alias}.extraGroups = ["plugdev"];
}

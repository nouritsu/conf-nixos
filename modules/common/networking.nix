{usrconf, ...}: {
  networking = {
    networkmanager.enable = true;
    hostName = usrconf.hostname;
  };
}

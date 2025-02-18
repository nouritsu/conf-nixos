{hostname, ...}: {
  networking = {
    networkmanager.enable = true;
    hostName = hostname;
  };
}

{hostname, ...}: {
  networking = {
    networkManager.enable = true;
    wireless.enable = true;
    hostName = hostname;
  };
}

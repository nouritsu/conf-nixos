{
  usrconf,
  pkgs,
  ...
}: {
  networking = {
    networkmanager.enable = true;
    hostName = usrconf.hostname;
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}

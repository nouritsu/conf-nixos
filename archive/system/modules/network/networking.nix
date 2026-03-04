{
  config,
  pkgs,
  ...
}: {
  networking = {
    networkmanager.enable = true;
    hostName = config.my.system.hostname;
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}

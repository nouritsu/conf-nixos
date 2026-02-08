{pkgs, ...}: {
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = [
    pkgs.ifuse
    pkgs.libimobiledevice
  ];
}

{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.swww
  ];
}

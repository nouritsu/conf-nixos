{pkgs, ...}: {
  home.packages = [
    pkgs.docker
    pkgs.lazydocker
  ];
}

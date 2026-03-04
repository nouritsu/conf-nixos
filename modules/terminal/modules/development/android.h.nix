{pkgs, ...}: {
  home.packages = [
    pkgs.android-tools
    pkgs.slint-viewer
  ];
}

{pkgs, ...}: {
  home.packages = [
    pkgs.pdftk
    pkgs.poppler-utils
  ];
}

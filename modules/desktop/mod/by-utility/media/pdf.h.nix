{pkgs, ...}: {
  home.packages = [
    pkgs.pdfchain
    pkgs.kdePackages.okular
  ];
}

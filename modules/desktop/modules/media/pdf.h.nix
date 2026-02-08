{pkgs, ...}: {
  home.packages = [
    pkgs.pdfchain
    pkgs.kdePackages.okular

    pkgs.zathura
    pkgs.zathuraPkgs.zathura_pdf_mupdf
  ];
}

{pkgs, ...}: {
  packages = [
    pkgs.typst
    pkgs.tinymist
    pkgs.typstyle
  ];

  treefmt.config.programs.typstyle.enable = true;

  scripts.live.exec = ''typst watch --open "''${1:-main.typ}"'';

  enterTest = "typst compile main.typ";
}

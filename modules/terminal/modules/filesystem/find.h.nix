{lib, pkgs, ...}: let
  fd = lib.getExe pkgs.fd;
  fzf = lib.getExe pkgs.fzf;
  rg = lib.getExe' pkgs.ripgrep "rg";
  rga = lib.getExe' pkgs.ripgrep-all "rga";
in {
  home.packages = [
    pkgs.ripgrep # rg
    pkgs.ripgrep-all # rga
    pkgs.fzf
  ];

  home.shellAliases = rec {
    find = "${fd} --no-ignore";
    findh = "${find} --hidden";

    findg = "${fd}";
    findhg = "${findg} --hidden";

    fz = fzf;

    grep = rg;

    grepa = rga;
    grep-all = grepa;
  };

  programs.fish.plugins = [
    {
      name = "fzf-fish";
      src = pkgs.fishPlugins.fzf-fish.src;
    }
  ];
}

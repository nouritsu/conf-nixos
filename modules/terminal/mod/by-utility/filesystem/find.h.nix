{pkgs, ...}: let
  fd = "${pkgs.fd}/bin/fd";
  fzf = "${pkgs.fzf}/bin/fzf";
  ripgrep = "${pkgs.ripgrep}/bin/rg";
  ripgrep-all = "${pkgs.ripgrep-all}/bin/rga";
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

    grep = ripgrep;

    grepa = ripgrep-all;
    grep-all = grepa;
  };

  programs.fish.plugins = [
    {
      name = "fzf-fish";
      src = pkgs.fishPlugins.fzf-fish.src;
    }
  ];
}

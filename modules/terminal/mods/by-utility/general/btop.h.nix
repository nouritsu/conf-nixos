{pkgs, ...}: let
  btop = "${pkgs.btop}/bin/btop";
in {
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      proc_tree = true;
      proc_gradient = false;
      base_10_sizes = true;
      update_ms = 1000;
    };
  };

  home.shellAliases = rec {
    top = btop;
    bottom = top;
  };
}

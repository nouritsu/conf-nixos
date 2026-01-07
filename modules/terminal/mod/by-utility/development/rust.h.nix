{pkgs, ...}: let
  evcxr = "${pkgs.evcxr}/bin/evcxr";
in {
  home.packages = [
    pkgs.rustup
    pkgs.bacon
    pkgs.evcxr
  ];

  home.shellAliases = {
    repl-rs = evcxr;
  };

  programs.fish = {
    interactiveShellInit = ''
      fish_add_path ~/.cargo/bin
    '';
  };
}

{lib, pkgs, ...}: let
  any-nix-shell = lib.getExe pkgs.any-nix-shell;
in {
  home.packages = [
    pkgs.any-nix-shell
  ];

  programs.fish.interactiveShellInit =
    /*
    fish
    */
    ''
      ${any-nix-shell} fish --info-right | source
    '';
}

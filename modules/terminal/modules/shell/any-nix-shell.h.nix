{pkgs, ...}: {
  home.packages = [
    pkgs.any-nix-shell
  ];

  programs.fish.interactiveShellInit =
    /*
    fish
    */
    ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
}

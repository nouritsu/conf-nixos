{
  pkgs,
  nixvim,
  ...
}: {
  imports = [
    ./core/default.nix
    ./development/default.nix
  ];
}

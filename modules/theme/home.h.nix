{inputs, ...}: {
  imports = [
    ./catppuccin.h.nix
    ./stylix.h.nix
    inputs.catppuccin.homeModules.catppuccin
  ];
}

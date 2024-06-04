{ ... }: {
  imports = [
    ./bootloader.nix
    ./fonts.nix
    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./pipewire.nix
    ./services.nix
  ];
}

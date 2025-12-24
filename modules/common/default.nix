{...}: {
  imports = [
    ./bluetooth.nix
    ./env.nix
    ./keyboard.nix
    ./locale.nix
    ./networking.nix
    ./kernel.nix
    ./nixconfig.nix
    ./nvidia.nix
    ./services.nix
    ./grub.nix # bootloader
    ./user.nix
  ];
}

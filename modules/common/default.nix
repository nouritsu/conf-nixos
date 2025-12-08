{...}: {
  imports = [
    ./env.nix
    ./locale.nix
    ./networking.nix
    ./nixconfig.nix
    ./services.nix
    ./grub.nix # bootloader
    ./user.nix
  ];
}

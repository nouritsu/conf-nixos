{...}: {
  imports = [
    ./env.nix
    ./locale.nix
    ./networking.nix
    ./nixconfig.nix
    ./services.nix
    ./systemd-boot.nix # bootloader
    ./user.nix
  ];
}

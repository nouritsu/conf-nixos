{...}: {
  imports = [
    ./bluetooth.nix
    ./env.nix
    ./graphics.nix
    ./grub.nix # bootloader
    ./keyboard.nix
    ./locale.nix
    ./networking.nix
    ./nixconfig.nix
    ./openrazer.nix
    ./services.nix
    ./user.nix
  ];
}

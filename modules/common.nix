{ ... }: {
  imports = [
    ./applications.nix
    ./bootloader.nix
    ./de.nix
    ./development.nix
    # ./dm.nix
    ./fonts.nix
    ./locale.nix
    ./neovim.nix
    ./networking.nix
    ./pipewire.nix
    ./services.nix
    ./shell.nix
    ./terminal.nix
    ./utils.nix
  ];

  environment.sessionVariables = { FLAKE = "nix"; };
}

{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/gaming.nix
    ../../modules/nvidia.nix
  ];

  # Networking
  networking.hostName = "nouritsu";

  # Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # User Account
  users.users.nouritsu = {
    isNormalUser = true;
    description = "Aneesh Bhave";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

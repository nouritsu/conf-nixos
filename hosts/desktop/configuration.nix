{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/gaming.nix
    ../../modules/nvidia.nix
  ];

  # Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # User Account
  users.users.nouritsu = {
    isNormalUser = true;
    description = "Aneesh Bhave";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  networking.hostName = "nouritsu";
  nixpkgs.config.allowUnfree = true;

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "23.05";
}

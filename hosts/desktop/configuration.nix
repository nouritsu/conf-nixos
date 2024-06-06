{ inputs, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # User Account
  users.users.nouritsu = {
    isNormalUser = true;
    description = "Aneesh Bhave";
    extraGroups = [ "networkmanager" "wheel" "openrazer" ];
  };
  networking.hostName = "nouritsu";
  nixpkgs.config.allowUnfree = true;

  # Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { nouritsu = import ./home.nix; };
  };

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "23.05";
}

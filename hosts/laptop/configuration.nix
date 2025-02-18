{user, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  users.users.aneesh = {
    isNormalUser = true;
    description = user.name;
    extraGroups = ["networkmanager" "wheel"];
  };
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "24.11"; # Did you read the comment?
}

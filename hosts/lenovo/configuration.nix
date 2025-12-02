{user, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  users.users.aneesh = {
    isNormalUser = true;
    description = user.name;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ddSNujKwebjyvbAPABcQU6hB/MD+WcbNwIyWRCo/N"
    ];
  };
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "25.11";
}

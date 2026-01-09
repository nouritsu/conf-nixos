{config, ...}: {
  users.users.${config.my.user.alias} = {
    isNormalUser = true;
    description = config.my.user.name;
    extraGroups = ["wheel" "networkmanager" "audio" "plugdev" "input"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ddSNujKwebjyvbAPABcQU6hB/MD+WcbNwIyWRCo/N"
    ];
  };
}

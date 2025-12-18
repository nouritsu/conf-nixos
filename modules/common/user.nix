{usrconf, ...}: {
  users.users.${usrconf.user.alias} = {
    isNormalUser = true;
    description = usrconf.user.name;
    extraGroups = ["networkmanager" "wheel" "audio" "plugdev"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ddSNujKwebjyvbAPABcQU6hB/MD+WcbNwIyWRCo/N"
    ];
  };
}

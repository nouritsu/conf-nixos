{config, ...}: {
  users.users.${config.my.user.alias} = {
    isNormalUser = true;
    description = config.my.user.name;
    extraGroups = ["wheel" "networkmanager" "audio" "plugdev" "input"];
  };
}

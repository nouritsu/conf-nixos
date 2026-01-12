{config, ...}: {
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  boot.specialFileSystems."/dev/binderfs" = {
    device = "binder";
    fsType = "binder";
    options = ["max=1024"];
  };

  users.users.${config.my.user.alias}.extraGroups = ["docker"];
}

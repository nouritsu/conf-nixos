{
  lib,
  config,
  ...
}: let
  is_systemd-boot = config.my.boot.loader == "systemd";
in
  lib.mkIf is_systemd-boot {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  }

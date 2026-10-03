{den, ...}: {
  # Lenovo IdeaPad Slim 5 (Intel)
  den.aspects.lenovo = {
    includes = with den.aspects; [
      laptop
      bootloader.grub
      firmware.intel
      firmware.updates
      graphics.intel
      power.thermald
      dms.ideapad

      ssh.from-pc
      nix.from-pc
      nix.builds-from-pc
    ];
  };
}

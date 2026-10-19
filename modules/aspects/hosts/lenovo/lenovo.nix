{den, ...}: {
  # Lenovo IdeaPad Slim 5 (Intel)
  den.aspects.lenovo = {
    includes = with den.aspects; [
      laptop
      bootloader.limine
      firmware.intel
      firmware.updates
      graphics.intel
      power.thermald
      dms.ideapad

      ssh.from-pc
      ssh.from-pixel
      nix.from-pc
      nix.builds-from-pc
    ];
  };
}

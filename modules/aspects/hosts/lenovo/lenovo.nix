{den, ...}: {
  # Lenovo IdeaPad Slim 5 (Intel).
  den.aspects.lenovo = {
    includes = with den.aspects; [
      laptop

      # Plain GRUB rather than lanzaboote — this host does not need
      # Secure Boot, so it does not need sbctl keys enrolled either.
      bootloader.grub

      firmware.intel
      firmware.updates
      graphics.intel
      power.thermald

      # Inbound ssh from the desktop.
      ssh.from-pc
    ];
  };
}

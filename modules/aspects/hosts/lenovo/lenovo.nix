{den, ...}: {
  # Lenovo IdeaPad Slim 5 (Intel)
  den.aspects.lenovo = {
    includes = with den.aspects; [
      laptop
      bootloader.limine
      kernel.cachyos-bore-lto
      firmware.intel
      firmware.updates
      graphics.intel
      power.thermald
      dux.ideapad
      extra.clipping.in-game
      shatterlock.laptop

      ssh.from-pc
      ssh.from-pixel
      nix.from-pc
      nix.builds-from-pc
    ];
  };
}

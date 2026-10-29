{den, ...}: {
  # Lenovo IdeaPad Slim 5 (Intel)
  den.aspects.laptop = {
    includes = with den.aspects; [
      portable
      bootloader.limine
      bootloader.secure-boot
      filesystem.snapshots
      kernel.cachyos-bore-lto
      firmware.intel
      firmware.updates
      graphics.intel
      power.thermald
      dux.ideapad
      extra.clipping.in-game
      shatterlock.laptop

      secrets
      dux.calendar
      syncthing
      syncthing.laptop

      ssh.from-pc
      ssh.from-pixel
      nix.from-pc
      nix.builds-from-pc
    ];

    nixos = {
      sops.defaultSopsFile = ./secrets.yaml;

      # made on install; enroll-keys -m -f in Setup Mode after the first boot
      boot.loader.limine.secureBoot.autoGenerateKeys = true;
    };
  };
}

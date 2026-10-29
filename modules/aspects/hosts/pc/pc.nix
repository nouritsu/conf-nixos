{den, ...}: {
  den.aspects.pc = {
    includes = with den.aspects; [
      workstation
      bootloader.limine
      bootloader.secure-boot
      bootloader.windows
      kernel.cachyos-bore-lto
      firmware.amd
      graphics.nvidia
      cpu.balanced

      # Desk hardware
      peripherals.keyboard
      peripherals.monitor
      peripherals.tablet
      peripherals.razer
      dux.razer
      audio.presets

      secrets
      dux.home-assistant
      services.beszel
      extra.streaming
      extra.clipping.always-on
      nix.serve
      nix.builds-on-laptop
      nix.update

      ssh.from-laptop
      ssh.from-pixel
      backup.from-homelab
    ];
  };
}

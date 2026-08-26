{den, ...}: {
  den.aspects.pc = {
    includes = with den.aspects; [
      workstation
      bootloader.lanzaboote
      kernel.cachyos-bore-lto
      firmware.amd
      graphics.nvidia

      # Desk-bound hardware: Wooting keyboard, DDC/CI monitor control,
      # drawing tablet. These live here rather than in the desktop role
      # so portable hosts do not drag them in.
      peripherals.keyboard
      peripherals.monitor
      peripherals.tablet

      # sops-nix age key lives on this host only, so both the secret
      # store and the beszel agent that consumes it are pc-scoped.
      secrets
      services.beszel
    ];
  };
}

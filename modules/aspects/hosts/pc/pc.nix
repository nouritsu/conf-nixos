{den, ...}: {
  den.aspects.pc = {
    includes = with den.aspects; [
      workstation
      bootloader.lanzaboote
      kernel.cachyos-bore-lto
      firmware.amd
      graphics.nvidia
      cpu.balanced

      # Desk-bound hardware: Wooting keyboard, DDC/CI monitor control,
      # drawing tablet, Razer peripherals. These live here rather than in a
      # role so portable hosts do not drag them in.
      peripherals.keyboard
      peripherals.monitor
      peripherals.tablet
      peripherals.razer

      # sops-nix age key lives on this host only, so both the secret
      # store and the beszel agent that consumes it are pc-scoped.
      secrets
      services.beszel

      # Inbound ssh from the laptop.
      ssh.from-laptop
    ];
  };
}

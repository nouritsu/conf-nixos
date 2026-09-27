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

      # sops-nix age key lives on this host only, so the secret store and
      # everything that consumes it -- the beszel agent, the binary cache's
      # signing key -- are pc-scoped.
      secrets
      services.beszel
      nix.serve

      # Inbound ssh from the laptop.
      ssh.from-laptop
    ];
  };
}

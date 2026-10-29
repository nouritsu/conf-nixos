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
      dux.calendar
      services.beszel
      extra.streaming
      extra.clipping.always-on
      shatterlock.desktop
      nix.serve
      nix.builds-on-laptop
      nix.update

      ssh.from-laptop
      ssh.from-pixel
      backup.from-homelab
    ];

    nixos = {
      host,
      lib,
      ...
    }: let
      owner = lib.head (lib.attrNames host.users);
    in {
      sops.defaultSopsFile = ./secrets.yaml;

      # home assistant: the dux widget and claude's mcp
      sops.secrets."ha-pc-token" = {inherit owner;};
      sops.secrets."ha-claude-token" = {inherit owner;};
    };
  };
}

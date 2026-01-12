{...}: {
  imports = [
    # audio
    audio/pipewire.nix
    # boot
    boot/grub.nix
    boot/systemd-boot.nix
    # graphics
    graphics/graphics.nix
    graphics/nvidia.nix
    # i18n
    i18n/locale.nix
    i18n/timezone.nix
    # kernel
    kernel/cachyos-bore-lto.nix
    # networking
    networking/avahi.nix
    networking/bluetooth.nix
    networking/networking.nix
    networking/ssh.nix
    # nix
    nix/cache.nix
    nix/maintainence.nix
    nix/misc.nix
    nix/nh.nix
    nix/overlays.nix
    # peripherals
    peripherals/keyboard.nix
    # security
    security/keyring.nix
    security/polkit.nix
    security/rtkit.nix
    security/firewall.nix
    # misc services
    services/printing.nix
    services/udev.nix
    services/xserver.nix
    # user
    user/aneesh.nix
    # virtualization
    ./virtualization/docker.nix
    ./virtualization/waydroid.nix
  ];
}

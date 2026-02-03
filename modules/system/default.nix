{...}: {
  imports = [
    # audio
    modules/audio/pipewire.nix

    # boot
    modules/boot/grub.nix
    modules/boot/systemd-boot.nix

    # driver
    modules/driver/drivers.nix

    # filesystem
    modules/filesystem/exfat.nix
    modules/filesystem/ntfs.nix

    # graphics
    modules/graphics/graphics.nix
    modules/graphics/nvidia.nix

    # i18n
    modules/i18n/locale.nix
    modules/i18n/timezone.nix

    # kernel
    modules/kernel/cachyos-bore-lto.nix

    # network
    modules/network/avahi.nix
    modules/network/bluetooth.nix
    modules/network/dns.nix
    modules/network/networking.nix
    modules/network/ssh.nix

    # nix
    modules/nix/cache.nix
    modules/nix/maintainence.nix
    modules/nix/misc.nix
    modules/nix/nh.nix
    modules/nix/overlays.nix

    # peripherals
    modules/peripherals/keyboard.nix

    # security
    modules/security/keyring.nix
    modules/security/polkit.nix
    modules/security/rtkit.nix
    modules/security/firewall.nix

    # misc services
    modules/services/printing.nix
    modules/services/udev.nix
    modules/services/xserver.nix

    # user
    modules/user/aneesh.nix

    # virtualization
    modules/virtualization/docker.nix
    modules/virtualization/waydroid.nix
  ];
}

{den, ...}: {
  den.aspects.base.includes = with den.aspects; [
    bootloader
    nix
    network
    network.avahi
    network.dns-pihole
    network.dns-cloudflare
    security
    security.keyring
    security.trust-homelab
    i18n
    i18n.tz-germany
    filesystem
    filesystem.exfat
    filesystem.ntfs
    filesystem.btrfs
    filesystem.xfs
    firmware.redist
    ssh
    yazi
    shell
    starship
  ];
}

{
  flake.nixosModules = {
    fs-base = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.parted
        pkgs.gparted-full
      ];
    };

    fs-exfat = {pkgs, ...}: {
      boot.supportedFilesystems = [
        "exfat"
      ];

      environment.systemPackages = [
        pkgs.exfatprogs
      ];
    };

    fs-btrfs = {pkgs, ...}: {
      boot.supportedFilesystems = [
        "btrfs"
      ];

      environment.systemPackages = [
        pkgs.btrfs-progs
        pkgs.compsize
        pkgs.snapper
        pkgs.snapper-gui
      ];
    };

    fs-xfs = {pkgs, ...}: {
      boot.supportedFilesystems = [
        "xfs"
      ];

      environment.systemPackages = [
        pkgs.xfsprogs
        pkgs.xfsdump
      ];
    };
    fs-ntfs = {pkgs, ...}: {
      boot.supportedFilesystems = [
        "ntfs"
      ];

      environment.systemPackages = [
        pkgs.ntfs3g
      ];
    };
  };
}

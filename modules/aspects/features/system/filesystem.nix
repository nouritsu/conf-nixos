{
  den.aspects.filesystem = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.parted
        pkgs.gparted-full
      ];
    };

    provides = {
      exfat.nixos = {pkgs, ...}: {
        boot.supportedFilesystems = ["exfat"];
        environment.systemPackages = [pkgs.exfatprogs];
      };

      btrfs.nixos = {pkgs, ...}: {
        boot.supportedFilesystems = ["btrfs"];
        environment.systemPackages = [
          pkgs.btrfs-progs
          pkgs.compsize
          pkgs.snapper
          pkgs.snapper-gui
        ];
      };

      xfs.nixos = {pkgs, ...}: {
        boot.supportedFilesystems = ["xfs"];
        environment.systemPackages = [
          pkgs.xfsprogs
          pkgs.xfsdump
        ];
      };

      ntfs.nixos = {pkgs, ...}: {
        boot.supportedFilesystems = ["ntfs"];
        environment.systemPackages = [pkgs.ntfs3g];
      };
    };
  };
}

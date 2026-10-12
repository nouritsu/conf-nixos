{
  den.aspects.filesystem = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.parted
        pkgs.gparted-full
      ];
    };

    provides = {
      exfat.nixos = {
        boot.supportedFilesystems = ["exfat"];
      };

      btrfs.nixos = {pkgs, ...}: {
        boot.supportedFilesystems = ["btrfs"];
        environment.systemPackages = [
          pkgs.compsize
          pkgs.snapper
          pkgs.snapper-gui
        ];
      };

      xfs.nixos = {pkgs, ...}: {
        boot.supportedFilesystems = ["xfs"];
        environment.systemPackages = [pkgs.xfsdump];
      };

      ntfs.nixos = {pkgs, ...}: {
        boot.supportedFilesystems = ["ntfs"];
        environment.systemPackages = [pkgs.ntfs3g];
      };
    };
  };
}

{
  den.aspects.filesystem = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = [
        pkgs.parted
        pkgs.gparted-full
      ];

      which-key'.menu.s.submenu.d = {
        desc = "GParted";
        icon = "f02ca";
        cmd = lib.getExe pkgs.gparted-full;
        app-id = "gparted";
      };
    };

    provides = {
      exfat.nixos = {
        boot.supportedFilesystems = ["exfat"];
      };

      btrfs.nixos = {
        pkgs,
        lib,
        ...
      }: {
        boot.supportedFilesystems = ["btrfs"];
        environment.systemPackages = [
          pkgs.compsize
          pkgs.snapper
          pkgs.snapper-gui
        ];

        which-key'.menu.s.submenu.s = {
          desc = "Snapper";
          icon = "f02da";
          cmd = lib.getExe pkgs.snapper-gui;
          app-id = "snapper";
        };
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

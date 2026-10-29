{inputs, ...}: {
  den.aspects.filesystem = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      imports = [inputs.disko.nixosModules.disko];

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

      # snapper timelines for /home and the folders split out of it
      snapshots.nixos = {
        host,
        config,
        lib,
        ...
      }: let
        owner = lib.head (lib.attrNames host.users);
        user = config.users.users.${owner};

        # own subvolume and snapper config each
        folders = ["Assignments" "Documents" "Music" "Pictures" "Projects" "Videos"];
        # own subvolume, never snapshotted
        skipped = ["Games" ".cache"];

        timeline = {
          ALLOW_USERS = [owner];
          SYNC_ACL = true;
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 12;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 4;
          TIMELINE_LIMIT_MONTHLY = 3;
          TIMELINE_LIMIT_YEARLY = 0;
        };

        subvol = dir: "v ${user.home}/${dir} 0755 ${owner} ${user.group} -";
        # snapper needs a root-owned .snapshots subvolume in each
        snapshots = dir: "v ${dir}/.snapshots 0750 root root -";
      in {
        services.snapper = {
          # catch up after sleep or shutdown
          persistentTimer = true;
          configs =
            {home = timeline // {SUBVOLUME = "/home";};}
            // lib.genAttrs' folders (dir: lib.nameValuePair (lib.toLower dir) (timeline // {SUBVOLUME = "${user.home}/${dir}";}));
        };

        # v turns missing paths into subvolumes; nested ones stay out of /home snapshots
        systemd.tmpfiles.rules =
          [(snapshots "/home")]
          ++ lib.concatMap (dir: [(subvol dir) (snapshots "${user.home}/${dir}")]) folders
          ++ map subvol skipped;
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

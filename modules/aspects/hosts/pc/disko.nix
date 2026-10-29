{
  den.aspects.pc.nixos = {
    # holds data: never run disko's format or destroy modes against this disk
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-CT2000T705SSD3_2520E9BE9DEE";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };

          root = {
            # the existing swap partition
            end = "-35206M";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = let
                mountOptions = ["noatime"];
              in {
                "@root" = {
                  mountpoint = "/";
                  inherit mountOptions;
                };
                "@home" = {
                  mountpoint = "/home";
                  inherit mountOptions;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  inherit mountOptions;
                };
                "@log" = {
                  mountpoint = "/var/log";
                  inherit mountOptions;
                };
              };
            };
          };

          swap = {
            size = "100%";
            content.type = "swap";
          };
        };
      };
    };

    # sops reads the age key from ~ during activation
    fileSystems."/home".neededForBoot = true;

    services.btrfs.autoScrub.enable = true;
  };
}

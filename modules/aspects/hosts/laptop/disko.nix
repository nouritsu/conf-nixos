{
  den.aspects.laptop.nixos = {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPMQD-512G-1101_23163A453002";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };

          root = {
            # swap after it, the size of RAM
            end = "-16G";
            content = {
              type = "luks";
              name = "cryptroot";
              # only read while formatting
              passwordFile = "/tmp/luks.key";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
                crypttabExtraOpts = ["tpm2-device=auto"];
              };
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = let
                  mountOptions = ["compress=zstd:1" "noatime"];
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
          };

          swap = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptswap";
              passwordFile = "/tmp/luks.key";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = ["tpm2-device=auto"];
              };
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };

    # sops reads the age key from ~ during activation
    fileSystems."/home".neededForBoot = true;

    services.btrfs.autoScrub.enable = true;
  };
}

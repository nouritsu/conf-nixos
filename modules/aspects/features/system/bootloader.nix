{inputs, ...}: {
  den.aspects.bootloader = {
    nixos = {
      boot.loader.efi.canTouchEfiVariables = true;
    };

    provides = {
      # needs sbctl create-keys + enroll-keys in Setup Mode first
      lanzaboote.nixos = {
        pkgs,
        config,
        inputs',
        ...
      }: let
        rev = inputs.self.shortRev or inputs.self.dirtyShortRev or "unknown";
        kernel = config.boot.kernelPackages.kernel.modDirVersion;
      in {
        imports = [inputs.lanzaboote.nixosModules.lanzaboote];

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          configurationLimit = 10;

          # menu titles from the bootspec title below
          package = inputs'.lanzaboote.packages.lzbt.overrideAttrs (old: {
            patches = (old.patches or []) ++ [./lzbt-title.patch];
          });
        };

        # lzbt fills in @generation@
        boot.bootspec.extensions."org.nix-community.lanzaboote".title = "NixOS @generation@ ${rev} ${kernel}";

        # menu hidden, tap space to show it
        boot.loader.timeout = 0;

        boot.loader.systemd-boot.enable = false;

        environment.systemPackages = [pkgs.sbctl];
      };

      limine.nixos = {
        boot.loader.limine = {
          enable = true;
          maxGenerations = 10;
          # any key within the timeout shows the menu
          extraConfig = "quiet: yes";
          # no title
          style.interface.branding = "";
        };

        boot.loader.timeout = 1;
      };

      # Limine only; needs sbctl keys first; enroll-keys -m -f in Setup Mode
      secure-boot.nixos = {pkgs, ...}: {
        boot.loader.limine.secureBoot.enable = true;

        environment.systemPackages = [pkgs.sbctl];
      };

      # Limine only; reboots into the firmware's entry, so no hash to pin
      windows.nixos = {
        boot.loader.limine.extraEntries = ''
          /Windows
            protocol: efi_boot_entry
            entry: Windows Boot Manager
        '';
      };

      grub.nixos = {
        boot.loader.grub = {
          enable = true;
          efiSupport = true;
          device = "nodev"; # EFI only, no MBR
          configurationLimit = 10;
          # esc within the timeout shows the menu
          timeoutStyle = "hidden";
        };

        boot.loader.timeout = 1;
      };

      systemd-boot.nixos = {
        boot.loader.systemd-boot.enable = true;
      };

      # GRUB only
      os-prober.nixos = {
        boot.loader.grub.useOSProber = true;
      };
    };
  };
}

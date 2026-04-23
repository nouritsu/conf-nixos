{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.pc = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = with self.nixosModules; [
      opts-hm-modules

      # Host
      host-pc-base
      host-pc-hwconf

      # Nix
      # nixpkgs-base
      nixpkgs-unfree
      nix-base
      nix-cache
      home-manager-integration

      # Boot
      bootloader
      kernel-cachyos-bore-lto

      # Hardware
      audio
      bluetooth
      graphics-base
      graphics-nvidia
      firmware-redist
      firmware-amd

      # Services
      srv-beszel-agent
      srv-ollama

      # Peripherals
      peripheral-keyboard
      peripheral-monitor
      peripheral-tablet
      peripheral-razer

      # Network
      net-base
      net-avahi
      net-dns-pihole
      net-dns-cloudflare
      ssh-base

      # Filesystem
      fs-exfat
      fs-ntfs
      fs-btrfs
      fs-xfs

      # Security
      security-pki
      security-keyring
      security-polkit
      security-rtkit

      # Users
      user-aneesh
      secrets

      # i18n
      i18n-locale
      i18n-tz-germany

      # Virtualization
      virt-podman
      virt-emulate-aarch64
      virt-waydroid

      # Theme
      theme-catppuccin
      stylix-base
      stylix-catppuccin

      # Extra
      extra-printing
      extra-xserver

      # Desktop
      desktop-control
      desktop-wayland
      desktop-cursor
      desktop-xdg
      desktop-niri
      app-hyprlock
      app-tuigreet
      app-dms
      ai-opencode

      # Applications
      app-core
      app-fish
      app-git
      app-gh
      app-jujutsu
      app-delta
      app-helix
      app-nh
      app-starship
      app-yazi
      app-firefox
      app-brave
      # app-hyprpicker
      app-scrcpy
      app-screenshot
      app-steam
      app-web
      app-wezterm

      # Development
      dev-core
      dev-direnv
      dev-android
      dev-c
      dev-nix
      dev-python
      dev-rust

      # Extra (Applications)
      extra-tui-viewers
      extra-media
      extra-pdf
      extra-download
      extra-fetchers
    ];
  };

  flake.nixosModules = {
    host-pc-base = {...}: {
      networking.hostName = "pc";

      # ================================================================ #
      # =                         DO NOT TOUCH                         = #
      # ================================================================ #
      system.stateVersion = "25.11";
    };

    host-pc-hwconf = {
      config,
      lib,
      modulesPath,
      ...
    }: {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod"];
      boot.initrd.kernelModules = [];
      boot.kernelModules = ["kvm-amd"];
      boot.extraModulePackages = [];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/b88aad6a-c345-4f28-add2-d1a84739504d";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/A3A1-5954";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      swapDevices = [
        {device = "/dev/disk/by-uuid/94a1a4b4-511b-4fa4-8caa-1ceb1929af0a";}
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}

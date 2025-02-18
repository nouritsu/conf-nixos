{...}: {
  boot.loader = {
<<<<<<< HEAD
    grub = {
      enable = true;
      useOSProber = true;
      theme = pkgs.catppuccin-grub;
      device = "/dev/nvme0n1p1";
    };
=======
    systemd-boot.enable = true;
>>>>>>> c2eab88 (get system to a working state)
    efi.canTouchEfiVariables = true;
  };
}

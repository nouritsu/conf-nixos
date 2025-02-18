{pkgs, ...}: {
  boot.loader = {
    grub = {
      enable = true;
      useOSProber = true;
      theme = pkgs.catppuccin-grub;
    };
    efi.canTouchEfiVariables = true;
  };
}

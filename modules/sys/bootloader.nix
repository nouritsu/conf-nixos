{ pkgs, lib, ... }: {
  stylix.targets.grub.enable = false; # Disable stylix grub theme

  boot.loader = {
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
      theme = pkgs.sleek-grub-theme.override { withStyle = "dark"; };
    };
    efi.canTouchEfiVariables = true;
  };
}

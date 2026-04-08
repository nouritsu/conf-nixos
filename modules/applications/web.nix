{
  flake.nixosModules.app-web = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.telegram-desktop
      pkgs.whatsapp-electron
      pkgs.vesktop
    ];
  };
}

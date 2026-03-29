{
  flake.nixosModules.app-web = {pkgs, ...}: {
    my.hmModules = ["app-web"];

    environment.systemPackages = [
      pkgs.telegram-desktop
      pkgs.whatsapp-electron
    ];
  };

  flake.homeModules.app-web = {...}: {
    programs.vesktop.enable = true;
  };
}

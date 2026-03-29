{
  flake.nixosModules.app-woomer = {pkgs, ...}: {
    my.hmModules = ["app-woomer"];

    environment.systemPackages = [
      pkgs.woomer
    ];
  };

  flake.homeModules.app-woomer = {...}: {
    # TODO: NIRI
  };
}

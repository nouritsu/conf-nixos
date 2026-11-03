{
  den.aspects.nirius.nixos = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = [pkgs.nirius];

    systemd.user.services.niriusd = {
      description = "nirius daemon";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = lib.getExe' pkgs.nirius "niriusd";
        Restart = "on-failure";
      };
    };
  };
}

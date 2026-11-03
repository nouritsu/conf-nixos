{
  den.aspects.nfsm.nixos = {
    self',
    lib,
    ...
  }: {
    systemd.user.services.nfsm = {
      description = "niri fullscreen manager";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = lib.getExe self'.packages.nfsm;
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };
}

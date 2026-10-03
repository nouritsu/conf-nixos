{
  # ppd keeps its profile across reboots; reset it every boot
  # graphical.target: ppd is After=multi-user, that'd cycle
  den.aspects.cpu.provides.balanced.nixos = {
    pkgs,
    lib,
    ...
  }: {
    systemd.services.cpu-power-profile = {
      description = "Pin power-profiles-daemon to the balanced profile";
      wantedBy = ["graphical.target"];
      after = ["power-profiles-daemon.service"];
      requires = ["power-profiles-daemon.service"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe' pkgs.power-profiles-daemon "powerprofilesctl"} set balanced";
      };
    };
  };
}

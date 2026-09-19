{
  # power-profiles-daemon persists the selected profile to
  # /var/lib/power-profiles-daemon/state.ini, so the profile is mutable
  # state living outside this config: one stray tap on the DMS power OSD
  # sets `power-saver` and it silently survives every reboot after that.
  # `power-saver` clamps scaling_max_freq to base clock and strips the
  # boost range off entirely.
  #
  # Ordered against graphical.target rather than multi-user.target because
  # the daemon's own unit declares After=multi-user.target — hanging this
  # off multi-user would build an ordering cycle for systemd to break.
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

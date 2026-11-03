{
  den.aspects.nirinit.nixos = {
    self',
    pkgs,
    lib,
    ...
  }: let
    settings = (pkgs.formats.toml {}).generate "nirinit.toml" {
      # started at login already, or restore themselves
      skip.apps = [
        "steam"
        "vesktop"
        "com.github.wwmm.easyeffects"
        "proton.vpn.app.gtk"
        ".protonvpn-app-wrapped"
      ];
      launch.tuios = "${lib.getExe self'.packages.wezterm} start --class tuios -- ${lib.getExe pkgs.tuios} attach main -c";
    };
  in {
    # restores the last saved layout once at start, then saves every 5 min
    systemd.user.services.nirinit = {
      description = "niri session save and restore";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${lib.getExe self'.packages.nirinit} --config ${settings}";
        Restart = "always";
        PrivateTmp = true;
      };
    };
  };
}

{inputs, ...}: {
  den.aspects.niri-pip.nixos = {
    self',
    pkgs,
    lib,
    ...
  }: let
    niri-pip = self'.packages.niri-pip;

    # upstream's seeded config, minus the keys its settings page writes
    example = lib.importTOML "${inputs.niri-pip}/config/config.example.toml";
    pinned = (pkgs.formats.toml {}).generate "niri-pip.toml" (example
      // {
        general = removeAttrs example.general ["auto_detect" "remember_geometry" "follow_workspace" "follow_mode" "restore_layout_on_unpin"];
        pip = removeAttrs example.pip ["steal_focus" "preserve_aspect_ratio"];
        minimize = removeAttrs example.minimize ["enabled" "restore_focus"];
      });

    # pinned keys go over the live file; settings page edits to the rest stay
    pin = pkgs.writeScript "niri-pip-pin-settings" ''
      #!${pkgs.python3.withPackages (ps: [ps.tomli-w])}/bin/python3
      import copy, os, sys, tomllib, tomli_w

      live = os.path.join(os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config"), "niri-pip", "config.toml")
      with open(sys.argv[1], "rb") as f:
          pin = tomllib.load(f)
      try:
          with open(live, "rb") as f:
              cur = tomllib.load(f)
      except FileNotFoundError:
          cur = {}
      except tomllib.TOMLDecodeError:
          sys.exit(0)

      def merge(a, b):
          for k, v in b.items():
              if isinstance(v, dict) and isinstance(a.get(k), dict):
                  merge(a[k], v)
              else:
                  a[k] = v
          return a

      new = merge(copy.deepcopy(cur), pin)
      if new != cur:
          os.makedirs(os.path.dirname(live), exist_ok=True)
          with open(live + ".tmp", "wb") as f:
              tomli_w.dump(new, f)
          os.chmod(live + ".tmp", 0o600)
          os.replace(live + ".tmp", live)
    '';
  in {
    environment.systemPackages = [niri-pip];

    systemd.user.services.niripip = {
      description = "niri picture-in-picture daemon";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      startLimitIntervalSec = 0;
      serviceConfig = {
        ExecStartPre = "-${pin} ${pinned}";
        ExecStart = lib.getExe' niri-pip "niripipd";
        ExecReload = "${lib.getExe niri-pip} reload";
        Restart = "always";
        RestartSec = 1;
      };
    };
  };
}

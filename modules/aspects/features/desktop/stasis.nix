{
  den.aspects.stasis.nixos = {
    config,
    self',
    pkgs,
    lib,
    ...
  }: let
    stasis = lib.getExe pkgs.stasis;
    shatterlock = lib.getExe self'.packages.shatterlock;
    niri = lib.getExe' config.programs.niri.package "niri";

    # timeouts count from the step before; laptops on ac fall back to the desktop plan
    plan = ''
      default:
        debounce_seconds 0

        lock_screen:
          timeout 3600
          command "${shatterlock} lock"
        end

        dpms:
          timeout 30
          command "${niri} msg action power-off-monitors"
          resume_command "${niri} msg action power-on-monitors"
        end

        battery:
          lock_screen:
            timeout 600
            command "${shatterlock} lock"
          end

          dpms:
            timeout 30
            command "${niri} msg action power-off-monitors"
            resume_command "${niri} msg action power-on-monitors"
          end

          suspend:
            timeout 570
            command "systemctl suspend"
          end
        end
      end
    '';
  in {
    environment.systemPackages = [pkgs.stasis];

    environment.etc."stasis/stasis.rune".text = plan;

    systemd.user.services.stasis = {
      description = "stasis idle manager";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      # pw-dump for media, notify-send, niri msg windows for steam app ids
      path = [pkgs.pipewire pkgs.libnotify pkgs.systemd pkgs.bash pkgs.coreutils config.programs.niri.package];
      serviceConfig = {
        ExecStart = "${stasis} -c /etc/stasis/stasis.rune";
        Restart = "on-failure";
      };
    };

    # it reads the plan only at start
    system.userActivationScripts.stasis-reload.text = "${stasis} reload || true";
  };
}

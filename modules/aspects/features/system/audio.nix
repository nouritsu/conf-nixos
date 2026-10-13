{
  den.aspects.audio = {
    nixos = {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;

        alsa = {
          enable = true;
          support32Bit = true;
        };
      };
    };

    provides.rtkit.nixos = {
      security.rtkit.enable = true;
    };

    provides.mixer.nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.pavucontrol];
    };

    provides.fx.nixos = {
      self',
      pkgs,
      lib,
      ...
    }: let
      easyeffects = lib.getExe pkgs.easyeffects;
      wait-for-tray = lib.getExe self'.packages.wait-for-tray;
    in {
      environment.systemPackages = [pkgs.easyeffects];

      systemd.user.services.easyeffects = {
        description = "EasyEffects audio service";
        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target" "pipewire.service"];
        serviceConfig = {
          # it checks for a tray only at launch
          ExecStart = "${wait-for-tray} ${easyeffects} --service-mode --hide-window";
          Restart = "on-failure";
          Slice = "session.slice";
        };
      };
    };
  };
}

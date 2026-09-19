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

    user.extraGroups = ["audio"];

    provides.rtkit.nixos = {
      security.rtkit.enable = true;
    };

    provides.mixer.nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.pavucontrol];
    };

    provides.fx.nixos = {
      pkgs,
      lib,
      ...
    }: let
      easyeffects = lib.getExe pkgs.easyeffects;
    in {
      environment.systemPackages = [pkgs.easyeffects];

      systemd.user.services.easyeffects = {
        description = "EasyEffects audio service";
        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target" "pipewire.service"];
        serviceConfig = {
          ExecStart = "${easyeffects} --service-mode";
          Restart = "on-failure";
          Slice = "session.slice";
        };
      };
    };
  };
}

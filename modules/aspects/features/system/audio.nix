{
  den.aspects.audio = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;

        alsa = {
          enable = true;
          support32Bit = true;
        };
      };

      # sinks mirror their monitor; -d undoes
      programs.fish.interactiveShellInit = ''
        function mirror-audio --description 'play an audio device through a sink too'
          pw-link $argv
        end

        function __mirror_audio_nodes --argument-names class
          pw-dump | ${lib.getExe pkgs.jq} -r --arg class $class '.[].info.props? | select(."media.class"? // "" | test($class)) | "\(."node.name")\t\(."node.description")"'
        end

        complete -c mirror-audio -f
        complete -c mirror-audio -s d -l disconnect -d 'stop mirroring'
        complete -c mirror-audio -n '__fish_is_nth_token 1' -a '(__mirror_audio_nodes "^Audio/(Sink|Source)")'
        complete -c mirror-audio -n '__fish_is_nth_token 2' -a '(__mirror_audio_nodes "^Audio/Sink")'
      '';
    };

    provides.rtkit.nixos = {
      security.rtkit.enable = true;
    };

    provides.mixer.nixos = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = [pkgs.pavucontrol];

      which-key'.menu.s.submenu.a = {
        desc = "pavucontrol";
        icon = "f057e";
        cmd = lib.getExe pkgs.pavucontrol;
        app-id = "pavucontrol";
      };
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

      which-key'.menu.s.submenu.e = {
        desc = "EasyEffects";
        icon = "f0ea2";
        cmd = easyeffects;
        app-id = "easyeffects";
      };

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

    provides.presets.nixos = {pkgs, ...}: let
      mic = "alsa_input.usb-HP__Inc_HyperX_SoloCast_2_1H56020MH4-00.analog-stereo";
      headphones = "alsa_output.pci-0000_0d_00.4.analog-stereo";

      # device-profile is the pipewire route description, not the card profile
      autoload = name: device: description: route:
        pkgs.writeText "${name}-autoload.json" (builtins.toJSON {
          inherit device;
          device-description = description;
          device-profile = route;
          preset-name = name;
        });
      micAutoload = autoload "solocast2" mic "HyperX SoloCast 2 Analog Stereo" "Microphone";
      headphonesAutoload = autoload "headphones" headphones "Starship/Matisse HD Audio Controller Analog Stereo" "Line Out";

      micPreset = ./easyeffects-solocast2.json;
      headphonesPreset = ./easyeffects-headphones.json;
      pins = "${micPreset} ${micAutoload} ${headphonesPreset} ${headphonesAutoload}";
    in {
      # presets are read-only; GUI changes come back by saving a copy over the repo json
      systemd.user.tmpfiles.rules = [
        "L+ %h/.local/share/easyeffects/input/solocast2.json - - - - ${micPreset}"
        "L+ %h/.local/share/easyeffects/autoload/input/${mic}:Microphone.json - - - - ${micAutoload}"
        "L+ %h/.local/share/easyeffects/output/headphones.json - - - - ${headphonesPreset}"
        "L+ \"%h/.local/share/easyeffects/autoload/output/${headphones}:Line Out.json\" - - - - ${headphonesAutoload}"
      ];

      # presets only autoload when easyeffects sees the device appear
      system.userActivationScripts.easyeffects-presets = {
        deps = ["tmpfiles"];
        text = ''
          stamp=''${XDG_STATE_HOME:-$HOME/.local/state}/easyeffects-presets-pin
          if [ "$(cat "$stamp" 2>/dev/null)" != "${pins}" ]; then
            mkdir -p "$(dirname "$stamp")"
            echo "${pins}" > "$stamp"
            ${pkgs.systemd}/bin/systemctl --user --no-block try-restart easyeffects.service || true
          fi
        '';
      };
    };
  };
}

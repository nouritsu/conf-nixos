{
  den.aspects.services.provides = {
    printing.nixos = {
      services.printing.enable = true;
    };

    beszel.nixos = {config, ...}: {
      sops.secrets."beszel-token" = {};
      sops.secrets."beszel-key" = {};

      sops.templates."beszel.env".content = ''
        HUB_URL="https://monitor.nouritsu.com"
        KEY="${config.sops.placeholder."beszel-key"}"
        TOKEN="${config.sops.placeholder."beszel-token"}"
      '';

      services.beszel.agent = {
        enable = true;
        environmentFile = config.sops.templates."beszel.env".path;
        openFirewall = true;
      };
    };

    # the homelab's immich has no ml of its own; its queues wait while this is down
    immich-ml.nixos = {lib, ...}: let
      port = 3003;
      homelab = "192.168.178.128";
    in {
      hardware.nvidia-container-toolkit.enable = true;

      virtualisation.oci-containers.containers.immich-ml = {
        # the same release as the homelab's immich-server (conf-srv)
        image = "ghcr.io/immich-app/immich-machine-learning:v3.3.6-cuda@sha256:2c2721c54c5e245b095eea3eb0cda743d112a3f537555b39e2e9a112879a50c1";
        devices = ["nvidia.com/gpu=all"];
        # named volume, the models outlive the container
        volumes = ["immich-ml-cache:/cache"];
        # idle models unload inside the 60 s the homelab leaves between queues
        environment.MACHINE_LEARNING_MODEL_TTL = "30";
        # podman's published ports skip nixos-fw; on the host network the rule below applies
        extraOptions = ["--network=host"];
      };

      # games get the vram; the homelab pauses its queues until this answers again
      game-mode'.pauses = ["podman-immich-ml.service"];

      systemd.services.podman-immich-ml = {
        # the gpu only resolves once the cdi spec is written
        requires = ["nvidia-container-toolkit-cdi-generator.service"];
        after = ["nvidia-container-toolkit-cdi-generator.service"];

        # back after any exit; a stop, game mode's included, still stays down
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = "10s";
        };
      };

      # no auth of its own, so the homelab only
      # v6 is refused outright; a silent drop stalls the homelab before it tries v4
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp -s ${homelab} --dport ${toString port} -j nixos-fw-accept
        ip6tables -A nixos-fw -p tcp --dport ${toString port} -j REJECT --reject-with tcp-reset
      '';
    };
  };
}

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

    # the homelab's immich tries this ahead of its own, while the pc is on
    immich-ml.nixos = let
      port = 3003;
      homelab = "192.168.178.128";
    in {
      hardware.nvidia-container-toolkit.enable = true;

      virtualisation.oci-containers.containers.immich-ml = {
        # the same release as the homelab's immich-server (conf-srv)
        image = "ghcr.io/immich-app/immich-machine-learning:v3.3.6-cuda@sha256:2c2721c54c5e245b095eea3eb0cda743d112a3f537555b39e2e9a112879a50c1";
        devices = ["nvidia.com/gpu=all"];
        volumes = ["immich-ml-cache:/cache"];
        # podman's published ports skip nixos-fw; on the host network the rule below applies
        extraOptions = ["--network=host"];
      };

      # games get the vram; the homelab's immich falls back to its own within 30 s
      game-mode'.pauses = ["podman-immich-ml.service"];

      # the gpu only resolves once the cdi spec is written
      systemd.services.podman-immich-ml = {
        requires = ["nvidia-container-toolkit-cdi-generator.service"];
        after = ["nvidia-container-toolkit-cdi-generator.service"];
      };

      # no auth of its own, so the homelab only
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp -s ${homelab} --dport ${toString port} -j nixos-fw-accept
      '';
    };
  };
}

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
  };
}

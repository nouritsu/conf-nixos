{self, ...}: {
  flake.nixosModules = {
    srv-beszel-agent = {config, ...}: {
      imports = [
        self.nixosModules.beszel-secrets
      ];
      services.beszel.agent = {
        enable = true;
        environmentFile = config.sops.templates."beszel.env".path;
        openFirewall = true;
      };
    };

    beszel-secrets = {config, ...}: {
      sops.secrets."beszel-token" = {};
      sops.secrets."beszel-key" = {};

      sops.templates."beszel.env" = {
        content = ''
          HUB_URL="https://monitor.nouritsu.com"
          KEY="${config.sops.placeholder."beszel-key"}"
          TOKEN="${config.sops.placeholder."beszel-token"}"
        '';
      };
    };
  };
}

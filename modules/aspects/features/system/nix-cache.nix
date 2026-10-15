{
  den.aspects.nix = let
    port = 5000;
  in {
    serve.nixos = {config, ...}: {
      sops.secrets."nix-cache-key" = {};

      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [config.sops.secrets."nix-cache-key".path];
        settings = {
          bind = "[::]:${toString port}";

          # ahead of cache.nixos.org's 40
          priority = 30;
        };
      };

      # the FRITZ!Box keeps this off the internet
      networking.firewall.allowedTCPPorts = [port];
    };

    from-pc.nixos = {
      nh'.substituters = ["http://pc:${toString port}"];
      nix.settings.trusted-public-keys = ["pc-1:G8lNppMW3TfcMRxzUM/m9xwS8hv8jlWMP6H6paVblHE="];
    };
  };
}

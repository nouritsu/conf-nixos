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
      pkgs,
      lib,
      ...
    }: let
      url = "http://pc:${toString port}";
    in {
      # not in substituters: with pc off every nix command would stall on it
      nix.settings = {
        trusted-substituters = [url];
        trusted-public-keys = ["pc-1:G8lNppMW3TfcMRxzUM/m9xwS8hv8jlWMP6H6paVblHE="];
      };

      # nh os adds the cache only when pc answers
      programs.nh.package = pkgs.symlinkJoin {
        inherit (pkgs.nh) name meta;
        paths = [
          (pkgs.writeShellApplication {
            name = "nh";
            text = ''
              if [[ ''${1-} == os ]] && ${lib.getExe pkgs.curl} -sf -m 1 -o /dev/null ${url}/nix-cache-info; then
                NIX_CONFIG=$(printf 'extra-substituters = %s\n%s' ${url} "''${NIX_CONFIG-}")
                export NIX_CONFIG
              fi
              exec ${lib.getExe pkgs.nh} "$@"
            '';
          })

          # completions and the manpage; bin/nh is already taken above
          pkgs.nh
        ];
      };
    };
  };
}

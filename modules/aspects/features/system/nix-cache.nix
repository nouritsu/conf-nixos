{
  # The pc serves its /nix/store to the laptop over HTTP. Rebuilds here are
  # download-bound, and nearly all of the laptop's closure is already in the
  # pc's own system -- vendor binaries and local builds that no public cache
  # carries included -- so the laptop pulls it across the room instead.
  #
  # The two only reach each other over Wi-Fi, at about twice the internet's
  # speed, so NARs have to travel compressed to come out ahead: nix asks for
  # zstd and harmonia compresses on the fly.
  den.aspects.nix = let
    port = 5000;
  in {
    serve.nixos = {config, ...}: {
      # Signs every narinfo it serves, the pc's own builds included, so the
      # laptop keeps require-sigs. The public half is pinned in from-pc.
      sops.secrets."nix-cache-key" = {};

      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [config.sops.secrets."nix-cache-key".path];
        settings = {
          bind = "[::]:${toString port}";

          # Substituters are tried in ascending priority. The module's 50
          # sits behind cache.nixos.org's 40, which would leave this serving
          # only what upstream lacks.
          priority = 30;
        };
      };

      # The FRITZ!Box keeps this off the internet.
      networking.firewall.allowedTCPPorts = [port];
    };

    from-pc.nixos = {
      pkgs,
      lib,
      ...
    }: let
      url = "http://pc:${toString port}";
    in {
      # Allowed and trusted, but deliberately not in substituters: every nix
      # command that substitutes queries those, and with the pc off each one
      # stalls ~20s on ARP timeouts and retries (~4.5s away from home, where
      # the name fails to resolve).
      nix.settings = {
        trusted-substituters = [url];
        trusted-public-keys = ["pc-1:G8lNppMW3TfcMRxzUM/m9xwS8hv8jlWMP6H6paVblHE="];
      };

      # Rebuilds are what the cache is for, so `nh os` probes for it and adds
      # it only when it answers -- a pc that is off costs at most a second, and
      # `nix shell`, comma and the rest never wait on it.
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

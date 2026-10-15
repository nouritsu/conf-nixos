{
  inputs,
  lib,
  ...
}: {
  den.aspects.nix = {host, ...}: let
    primary = lib.head (lib.attrNames host.users);
  in {
    nixos = {
      config,
      pkgs,
      ...
    }: let
      substituters = config.nh'.substituters;
    in {
      imports = [
        inputs.nix-index-database.nixosModules.default
        {
          # caches only nh os uses, each added when it answers
          options.nh'.substituters = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
          };
        }
      ];

      programs.nix-ld.enable = true;
      programs.nix-index-database.comma.enable = true;

      programs.nh = {
        enable = true;
        flake = "${config.users.users.${primary}.home}/.config/nixos";

        clean.enable = true;
        clean.extraArgs = "--keep 5 --keep-since 7d";

        package = lib.mkIf (substituters != []) (pkgs.symlinkJoin {
          inherit (pkgs.nh) name meta;
          paths = [
            (pkgs.writeShellApplication {
              name = "nh";
              text = ''
                if [[ ''${1-} == os ]]; then
                  urls=(${lib.escapeShellArgs substituters})
                  for url in "''${urls[@]}"; do
                    if ${lib.getExe pkgs.curl} -sf --connect-timeout 1 -m 3 -o /dev/null "$url/nix-cache-info"; then
                      NIX_CONFIG=$(printf 'extra-substituters = %s\n%s' "$url" "''${NIX_CONFIG-}")
                      export NIX_CONFIG
                    fi
                  done
                fi
                exec ${lib.getExe pkgs.nh} "$@"
              '';
            })

            # completions and the manpage; bin/nh is already taken above
            pkgs.nh
          ];
        });
      };

      # not in substituters: devshells and every other nix command would query them
      nix.settings.trusted-substituters = substituters;

      programs.fish.shellAliases.conf = "$EDITOR $NH_FLAKE";
      programs.fish.shellAbbrs = {
        nhrb = "nh os boot";
        nhrs = "nh os switch";
        nhrt = "nh os test";
        nhca = "nh clean all";
        nhs = "nh search";
      };

      nix.settings.trusted-users = ["root" "@wheel"];
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nix.settings.always-allow-substitutes = true;

      # no global registry; /etc/nix/registry.json still has nixpkgs
      nix.settings.flake-registry = "";
      nix.channel.enable = false;

      nix.settings.extra-substituters = ["https://nix-community.cachix.org"];
      nix.settings.trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };
  };
}

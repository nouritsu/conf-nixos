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

      # /bin only, so not-found lookups take ms instead of seconds
      nix-index-small = (import inputs.nix-index-database {inherit pkgs;}).nix-index-with-small-db;
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

      # full db stays for nix-locate
      programs.nix-index.enableFishIntegration = false;
      programs.nix-index.enableBashIntegration = false;
      programs.bash.interactiveShellInit = "source ${nix-index-small}/etc/profile.d/command-not-found.sh";

      programs.nh = {
        enable = true;
        flake = "${config.users.users.${primary}.home}/.config/nixos";

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

        nd = "nix develop";
        nb = "nix build";
        nfu = "nix flake update";
        nfs = "nix flake show";
      };

      programs.fish.interactiveShellInit = ''
        abbr -a nr --set-cursor 'nix run nixpkgs#%'

        # nix-shell -p, but nix shell
        function nsp
          nix shell (string replace -r '^' 'nixpkgs#' -- $argv)
        end

        function fish_command_not_found
          set -l attrs (${lib.getExe nix-index-small} --minimal --no-group --type x --type s --whole-name --at-root /bin/$argv[1] | string replace -r '\.out$' "")
          if not set -q attrs[1]
            __fish_default_command_not_found_handler $argv
            return
          end

          # exact name, then prefixed, then shortest
          set attrs (for a in $attrs
              set -l rank 2
              string match -q -- "$argv[1]*" $a; and set rank 1
              test $a = $argv[1]; and set rank 0
              echo $rank (string length -- $a) $a
            end | sort -k1,1n -k2,2n | string split -f3 ' ')

          set -l lines (string pad -r -- ", "(string escape -- $argv | string join ' ') "nsp "$attrs[1..5])
          set -l notes "run once, alt-, adds the comma" "shell with it"
          echo "$argv[1] is not installed, but nixpkgs has it" >&2
          for i in (seq (count $lines))
            echo "  $lines[$i]" (set -q notes[$i]; and echo (set_color brblack)"# $notes[$i]"(set_color normal)) >&2
          end
          set -q attrs[6]; and echo "  "(set_color brblack)"# "(math (count $attrs) - 5)" more, comma lists them all"(set_color normal) >&2
        end

        # comma in front of the line, or of the last command if empty
        bind alt-comma 'fish_commandline_prepend ,'

        # packages for the libs a foreign binary can't find, for programs.nix-ld.libraries
        function nix-ld-missing
          set -l libs (LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH ldd $argv | string match -rg '^\s*(\S+) => not found$' | sort -u)
          set -q libs[1]; or return 0

          # one full-db scan for all of them
          set -l found (nix-locate --no-group --whole-name --at-root --regex '/lib/('(string escape --style=regex -- $libs | string join '|')')' \
            | string replace -r '^(\S+?)(\.out)?\s.*/(\S+)$' '$3 $1')
          for lib in $libs
            set -l attrs (string match -- "$lib *" $found | string split -f2 ' ' | sort -u)
            echo $lib: (set -q attrs[1]; and echo $attrs; or echo not in nixpkgs)
          end
        end
      '';

      nix.settings.trusted-users = ["root" "@wheel"];
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nix.settings.always-allow-substitutes = true;
      nix.settings.http-connections = 128;
      nix.settings.max-substitution-jobs = 128;

      # sources and build inputs survive nh clean, so rebuilds don't refetch them
      nix.settings.keep-outputs = true;

      # no global registry; /etc/nix/registry.json still has nixpkgs
      nix.settings.flake-registry = "";
      nix.channel.enable = false;

      nix.settings.extra-substituters = ["https://nix-community.cachix.org"];
      nix.settings.trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];

      # nix never repacks it, and every eval slows down with each fetch
      # never git gc or repack -ad it: it has no refs, so git drops every object
      systemd.user.services.nix-tarball-cache-repack = {
        description = "Repack the Nix tarball cache";
        path = [pkgs.git];
        unitConfig.ConditionPathIsDirectory = "%C/nix/tarball-cache-v2";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "%C/nix/tarball-cache-v2";
          Nice = 19;
          IOSchedulingClass = "idle";
        };
        script = ''
          git multi-pack-index write
          git multi-pack-index repack --batch-size 1024m
          git multi-pack-index expire
        '';
      };

      systemd.user.timers.nix-tarball-cache-repack = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };
  };
}

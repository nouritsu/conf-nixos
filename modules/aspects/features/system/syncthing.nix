{
  den.aspects.syncthing = {
    nixos = {
      host,
      config,
      pkgs,
      lib,
      ...
    }: let
      owner = lib.head (lib.attrNames host.users);
      user = config.users.users.${owner};
      cfg = config.services.syncthing;
      rest = "http://${cfg.guiAddress}/rest";

      devices = ["homelab" "pc" "laptop" "pixel"];
      deviceID = name: config.sops.placeholder."syncthing/ids/${name}";

      ignores = [
        # snapper's subvolume, readable through its acl
        "/.snapshots"
        "(?d).directory"
        "(?d)Thumbs.db"
        "(?d).DS_Store"
        ".~lock.*#"
        "~$*"
        "*.part"
        "*.crdownload"
      ];

      folders =
        lib.mapAttrsToList (id: f: {
          inherit id;
          inherit (f) label type devices;
          path = "${user.home}/${f.path}";
          stignore = pkgs.writeText "stignore-${id}" (lib.concatLines (ignores ++ f.ignores));
        })
        config.syncthing'.folders;

      peers = pkgs.writeShellApplication {
        name = "syncthing-peers";
        runtimeInputs = [pkgs.coreutils pkgs.curl pkgs.jq pkgs.libxml2];
        text = ''
          # ignores land before the first scan
          ${lib.concatMapStrings (f: ''
              mkdir -p ${lib.escapeShellArg f.path}
              install -m644 ${f.stignore} ${lib.escapeShellArg "${f.path}/.stignore"}
            '')
            folders}
          umask 077
          until key=$(xmllint --xpath 'string(configuration/gui/apikey)' ${lib.escapeShellArg "${cfg.configDir}/config.xml"}) && [ -n "$key" ]; do
            sleep 1
          done
          printf 'X-API-Key: %s\n' "$key" > "$RUNTIME_DIRECTORY/headers"
          until curl -fsS "${rest}/noauth/health" | jq -e '.status == "OK"' > /dev/null; do
            sleep 1
          done

          api() {
            curl -fsS -H "@$RUNTIME_DIRECTORY/headers" --retry 30 --retry-delay 1 --retry-all-errors "$@"
          }

          # PUT replaces the whole list
          api -X PUT --json @${config.sops.templates."syncthing-devices.json".path} "${rest}/config/devices"
          api -X PUT --json @${config.sops.templates."syncthing-folders.json".path} "${rest}/config/folders"
          ${lib.concatMapStrings (f: ''
              jq -Rn '{ignore: [inputs]}' ${f.stignore} | api --json @- "${rest}/db/ignores?folder=${f.id}" > /dev/null
            '')
            folders}
          if api "${rest}/config/restart-required" | jq -e .requiresRestart > /dev/null; then
            api -X POST "${rest}/system/restart" > /dev/null
          fi
        '';
      };
    in {
      imports = [
        {
          # per-host folder types, merged with the shared folders below
          options.syncthing'.folders = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                label = lib.mkOption {type = lib.types.str;};
                # under home
                path = lib.mkOption {type = lib.types.str;};
                type = lib.mkOption {
                  type = lib.types.enum ["sendreceive" "sendonly" "receiveonly"];
                  default = "sendreceive";
                };
                devices = lib.mkOption {type = lib.types.listOf (lib.types.enum devices);};
                ignores = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [];
                };
              };
            });
            default = {};
          };
        }
      ];

      # same device lists on every host, or syncthing offers the folder again
      syncthing'.folders = {
        documents = {
          label = "Documents";
          path = "Documents";
          devices = ["pc" "laptop" "homelab"];
        };
        assignments = {
          label = "Assignments";
          path = "Assignments";
          devices = ["pc" "laptop" "homelab"];
          ignores = [
            "(?d).direnv"
            "(?d).devenv"
            "(?d).venv"
            "(?d)__pycache__"
            "(?d).ipynb_checkpoints"
            "(?d)node_modules"
            "(?d)target"
            "(?d)result"
          ];
        };
        pictures = {
          label = "Pictures";
          path = "Pictures";
          devices = ["pc" "laptop" "homelab"];
          # phone-screenshots
          ignores = ["/Phone"];
        };
        books = {
          label = "Books";
          path = "Books";
          devices = ["pc" "laptop" "homelab" "pixel"];
        };
        wallpaper = {
          label = "Wallpaper";
          path = "wallpaper";
          devices = ["pc" "laptop"];
        };
        music = {
          label = "Music";
          path = "Music";
          devices = ["pc" "laptop" "pixel"];
        };
        phone-screenshots = {
          label = "Phone screenshots";
          path = "Pictures/Phone";
          type = "receiveonly";
          devices = ["pixel" "pc" "laptop" "homelab"];
        };
      };

      sops.secrets =
        {
          "syncthing/key" = {};
          "syncthing/cert" = {};
        }
        // lib.genAttrs (map (name: "syncthing/ids/${name}") devices) (_: {
          sopsFile = ../secrets/shared.yaml;
        });

      # device ids stay out of the store, so syncthing-peers pushes them over the api
      sops.templates."syncthing-devices.json" = {
        content = builtins.toJSON (map (name: {
            deviceID = deviceID name;
            inherit name;
            addresses = ["dynamic"];
            autoAcceptFolders = false;
            introducer = false;
          })
          devices);
        inherit owner;
        restartUnits = ["syncthing-peers.service"];
      };
      sops.templates."syncthing-folders.json" = {
        content = builtins.toJSON (map (f: {
            inherit (f) id label path type;
            devices = map (name: {deviceID = deviceID name;}) f.devices;
          })
          folders);
        inherit owner;
        restartUnits = ["syncthing-peers.service"];
      };

      services.syncthing = {
        enable = true;
        user = owner;
        inherit (user) group;
        dataDir = user.home;
        configDir = "${user.home}/.local/state/syncthing";
        # loopback only, no password
        guiAddress = "127.0.0.1:8384";
        openDefaultPorts = true;
        key = config.sops.secrets."syncthing/key".path;
        cert = config.sops.secrets."syncthing/cert".path;
        # syncthing-peers owns these
        overrideDevices = false;
        overrideFolders = false;
        settings.options = {
          urAccepted = -1;
          crashReportingEnabled = false;
        };
      };

      # hashing yields to games and the battery
      systemd.services.syncthing.serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
      };

      systemd.services.syncthing-peers = {
        description = "Syncthing devices and folders";
        requires = ["syncthing.service"];
        after = ["syncthing.service" "syncthing-init.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = owner;
          RuntimeDirectory = "syncthing-peers";
          ExecStart = lib.getExe peers;
        };
      };
    };

    # pc is the source for wallpaper and music
    provides.desktop.nixos.syncthing'.folders = {
      wallpaper.type = "sendonly";
      music.type = "sendonly";
    };

    provides.laptop.nixos.syncthing'.folders = {
      wallpaper.type = "receiveonly";
      music.type = "receiveonly";
    };
  };
}

{
  # launcher entries for the homelab's caddy endpoints and the router
  den.aspects.homelab.nixos = {
    config,
    host,
    inputs',
    pkgs,
    lib,
    self',
    ...
  }: let
    owner = lib.head (lib.attrNames host.users);
    domain = "nouritsu.com";

    # homarr-labs/dashboard-icons; variants picked to show on mocha
    icons = "${self'.packages.dashboard-icons}/svg";

    endpoints = {
      books = {
        name = "Bookshelf";
        description = "Ebook and audiobook library manager that finds and downloads books";
        icon = "readarr";
      };
      disks = {
        name = "Scrutiny";
        description = "Hard drive health monitor with SMART stats and failure alerts";
        icon = "scrutiny-light";
      };
      docs = {
        name = "Paperless";
        description = "Document archive that scans, OCRs and indexes paperwork";
        icon = "paperless-ngx";
      };
      files = {
        name = "copyparty";
        description = "File server for uploading, downloading and sharing files";
        icon = "copyparty";
      };
      home = {
        name = "Home Assistant";
        description = "Smart home automation, lights and device control";
        icon = "home-assistant";
      };
      indexes = {
        name = "Prowlarr";
        description = "Indexer manager that feeds torrent and usenet trackers to the arr apps";
        icon = "prowlarr";
      };
      mam = {
        name = "Mousehole";
        description = "Keeps the MyAnonamouse seedbox IP up to date";
        icon = "mousehole-dark";
      };
      monitor = {
        name = "Beszel";
        description = "Server monitor for CPU, memory, disk and container stats";
        icon = "beszel";
      };
      movies = {
        name = "Radarr";
        description = "Movie collection manager that downloads and upgrades films";
        icon = "radarr";
      };
      photos = {
        name = "Immich";
        description = "Photo and video library with phone backup, face recognition and smart search";
        icon = "immich";
      };
      pihole = {
        name = "Pi-hole";
        description = "Network-wide DNS ad blocker and query log";
        icon = "pi-hole";
        path = "/admin/";
      };
      player = {
        name = "Jellyfin";
        description = "Media server for streaming movies, shows and music";
        icon = "jellyfin";
      };
      router = {
        name = "FRITZ!Box";
        description = "Router admin for Wi-Fi, DHCP, port forwarding and the guest network";
        icon = "fritzbox-light";
        host = "fritz.box";
        scheme = "http";
      };
      share = {
        name = "Enclosed";
        description = "Encrypted note and file sharing with expiring links";
        icon = "enclosed-light";
      };
      shows = {
        name = "Sonarr";
        description = "TV show manager that downloads new episodes and series";
        icon = "sonarr";
      };
      sign = {
        name = "Documenso";
        description = "E-signature service for signing documents and contracts";
        icon = "documenso";
      };
      subs = {
        name = "Bazarr";
        description = "Subtitle downloader for movies and TV shows";
        icon = "bazarr";
      };
      sync = {
        name = "Syncthing";
        description = "Peer-to-peer file sync and backup between devices";
        icon = "syncthing";
      };
      torrent = {
        name = "qBittorrent";
        description = "BitTorrent client for downloading and seeding torrents";
        icon = "qbittorrent";
      };
      uptime = {
        name = "Gatus";
        description = "Uptime checks for every homelab and vps endpoint";
        icon = "gatus";
      };
      usenet = {
        name = "SABnzbd";
        description = "Usenet downloader for NZB files";
        icon = "sabnzbd";
      };
    };

    fqdn = subdomain: endpoints.${subdomain}.host or "${subdomain}.${domain}";
    address = subdomain: let
      e = endpoints.${subdomain};
    in "${e.scheme or "https"}://${fqdn subdomain}${e.path or ""}";
    open = subdomain: "${lib.getExe' pkgs.xdg-utils "xdg-open"} ${address subdomain}";

    entry = subdomain: e: let
      id = "homelab-${subdomain}";

      desktop = pkgs.makeDesktopItem {
        name = id;
        desktopName = e.name;
        genericName = fqdn subdomain;
        comment = e.description;
        keywords = ["homelab" subdomain];
        exec = open subdomain;
        icon = id;
        categories = ["Network"];
      };
    in
      pkgs.runCommand id {} ''
        install -Dm444 ${icons}/${e.icon}.svg $out/share/icons/hicolor/scalable/apps/${id}.svg
        install -Dm444 ${desktop}/share/applications/${id}.desktop -t $out/share/applications
      '';

    link = subdomain: icon: {
      desc = endpoints.${subdomain}.name;
      inherit icon;
      cmd = open subdomain;
    };

    # immich-desktop's colour roles
    roles = {
      background = "base";
      panel = "mantle";
      button = "surface0";
      border = "surface1";
      accent = "mauve";
      text = "text";
      mutedText = "subtext0";
    };

    # #aarrggbb, as qt writes them back
    theme = pkgs.runCommand "immich-desktop-mocha.ini" {nativeBuildInputs = [pkgs.jq];} ''
      jq -r --argjson roles ${lib.escapeShellArg (builtins.toJSON roles)} '
        .mocha.colors as $mocha
        | "[appearance]", "theme=custom",
          ($roles | to_entries[] | "customPalette\\\(.key)=#ff\($mocha[.value].hex[1:])")
      ' ${inputs'.catppuccin.packages.palette}/palette.json > $out
    '';

    # account + theme pinned on launch into its qsettings ini files
    immich-desktop = pkgs.symlinkJoin {
      inherit (self'.packages.immich-desktop) name meta;
      paths = [
        (pkgs.writeShellApplication {
          name = "immich";
          runtimeInputs = [pkgs.crudini];
          text = ''
            dir=''${XDG_CONFIG_HOME:-$HOME/.config}/Immich
            mkdir -p "$dir/profiles"

            # crudini is slow, skip it when every line is there
            pin() {
              local line content=""
              [ -f "$1" ] && content=$(< "$1")
              while IFS= read -r line; do
                case $'\n'$content$'\n' in
                  *$'\n'"$line"$'\n'*) ;;
                  *) crudini --ini-options=nospace --merge "$1" <<< "$2"; return ;;
                esac
              done <<< "$2"
            }

            pin "$dir/immich.ini" "$(< ${theme})" || true

            # legacy: the app's first profile; key via printf, off argv
            key=${config.sops.secrets."immich-api-key".path}
            if [ -r "$key" ]; then
              pin "$dir/profiles/legacy.ini" \
                "$(printf '[immich]\nserverUrl=%s\napiKey=%s' ${lib.escapeShellArg (address "photos")} "$(< "$key")")" || true
            fi

            exec ${lib.getExe self'.packages.immich-desktop} "$@"
          '';
        })
        self'.packages.immich-desktop
      ];
    };
  in {
    sops.secrets."immich-api-key" = {
      sopsFile = config.secrets'.shared;
      inherit owner;
    };

    environment.systemPackages = lib.mapAttrsToList entry endpoints ++ [immich-desktop];

    isup'.checks =
      lib.mapAttrs (subdomain: e: {
        inherit (e) name;
        group = "Homelab";
        url = address subdomain;
      })
      endpoints;

    which-key'.menu.h.submenu = {
      h = link "home" "f07d0";
      j = link "player" "f0230";
      p = link "pihole" "f0df1";
      r = link "router" "f0469";
      f = link "files" "f0870";
      d = link "docs" "f0219";
      s = link "sync" "f04e6";
      m = link "monitor" "f012a";
      k = link "disks" "f02ca";
      e = link "share" "f0497";
      g = link "sign" "f0dfc";
      a = {
        desc = "Arr stack";
        icon = "f01da";
        submenu = {
          r = link "movies" "f0381";
          s = link "shows" "f07f4";
          b = link "books" "f14f7";
          z = link "subs" "f0a16";
          p = link "indexes" "f0349";
          q = link "torrent" "f0347";
          n = link "usenet" "f0395";
          o = link "mam" "f1327";
        };
      };
    };
  };
}

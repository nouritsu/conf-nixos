{
  # launcher entries for the homelab's caddy endpoints and the router
  den.aspects.homelab.nixos = {
    pkgs,
    lib,
    self',
    ...
  }: let
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
      usenet = {
        name = "SABnzbd";
        description = "Usenet downloader for NZB files";
        icon = "sabnzbd";
      };
    };

    host = subdomain: endpoints.${subdomain}.host or "${subdomain}.${domain}";
    open = subdomain: let
      e = endpoints.${subdomain};
    in "${lib.getExe' pkgs.xdg-utils "xdg-open"} ${e.scheme or "https"}://${host subdomain}${e.path or ""}";

    entry = subdomain: e: let
      id = "homelab-${subdomain}";

      desktop = pkgs.makeDesktopItem {
        name = id;
        desktopName = e.name;
        genericName = host subdomain;
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
  in {
    environment.systemPackages = lib.mapAttrsToList entry endpoints;

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

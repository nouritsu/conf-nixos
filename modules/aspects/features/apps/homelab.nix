{
  # launcher entries for the homelab's caddy endpoints and the router
  den.aspects.homelab.nixos = {
    pkgs,
    lib,
    ...
  }: let
    domain = "nouritsu.com";

    # homarr-labs/dashboard-icons; variants picked to show on mocha
    icons = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/104a791794ef68b31bfecac676ddace8c223fd27/svg";

    endpoints = {
      books = {
        name = "Bookshelf";
        description = "Ebook and audiobook library manager that finds and downloads books";
        icon = "readarr";
        hash = "sha256-OK4OFxgz+CNCeMA6Gf4C74va0cscCqcdI4EfCWyguYg=";
      };
      disks = {
        name = "Scrutiny";
        description = "Hard drive health monitor with SMART stats and failure alerts";
        icon = "scrutiny-light";
        hash = "sha256-vTDfF+QuegrSgOshPCT42n4N9j69VFl08yx5CslstG8=";
      };
      docs = {
        name = "Paperless";
        description = "Document archive that scans, OCRs and indexes paperwork";
        icon = "paperless-ngx";
        hash = "sha256-rD9pCxUb3xTha+vqUnIReLN/9hmGYKEljslEXq+yuNA=";
      };
      files = {
        name = "copyparty";
        description = "File server for uploading, downloading and sharing files";
        icon = "copyparty";
        hash = "sha256-3gXFpBW2y1FIdTwSYRePrDdsWiWy7QeYdJKOGDHfV5g=";
      };
      home = {
        name = "Home Assistant";
        description = "Smart home automation, lights and device control";
        icon = "home-assistant";
        hash = "sha256-FGs2a4wJUCdCAlxLyk4Cno5KGyd9uDfVmiO5OUDr4OA=";
      };
      indexes = {
        name = "Prowlarr";
        description = "Indexer manager that feeds torrent and usenet trackers to the arr apps";
        icon = "prowlarr";
        hash = "sha256-zXc2vO9lUK2FPlnU1yBflunbiuRL6VfKW36ucEb1vGc=";
      };
      mam = {
        name = "Mousehole";
        description = "Keeps the MyAnonamouse seedbox IP up to date";
        icon = "mousehole-dark";
        hash = "sha256-E93wp2WdjRH13ZC7TgcBpbc5b8f8ijp2rSGYmCCC0GA=";
      };
      monitor = {
        name = "Beszel";
        description = "Server monitor for CPU, memory, disk and container stats";
        icon = "beszel";
        hash = "sha256-7gLbuxRxzKD0zOZ1AjB/fI5q5N1Vrhskc4LPHJeMEDY=";
      };
      movies = {
        name = "Radarr";
        description = "Movie collection manager that downloads and upgrades films";
        icon = "radarr";
        hash = "sha256-w9B+zfq0MsqX8mzwH+Btv8CZO1y2CTgns94cdCGm+5U=";
      };
      pihole = {
        name = "Pi-hole";
        description = "Network-wide DNS ad blocker and query log";
        icon = "pi-hole";
        hash = "sha256-RJRONKcheXwycc/GsV3/gc1vu/ZsfJbaU6NO05vgbqU=";
        path = "/admin/";
      };
      player = {
        name = "Jellyfin";
        description = "Media server for streaming movies, shows and music";
        icon = "jellyfin";
        hash = "sha256-f1PPCD27MRnsjFrL2AScUDMidhfkYVQPcFkawQkSQwY=";
      };
      router = {
        name = "FRITZ!Box";
        description = "Router admin for Wi-Fi, DHCP, port forwarding and the guest network";
        icon = "fritzbox-light";
        hash = "sha256-c67N8swA2nr/mN+Qaj9DV52K96viwCbmx2M2dcT9Iec=";
        host = "fritz.box";
        scheme = "http";
      };
      share = {
        name = "Enclosed";
        description = "Encrypted note and file sharing with expiring links";
        icon = "enclosed-light";
        hash = "sha256-AFJlW1C/TZ6cK5l0deb/pSEtUyH/+P7QnrGRPD/gJsk=";
      };
      shows = {
        name = "Sonarr";
        description = "TV show manager that downloads new episodes and series";
        icon = "sonarr";
        hash = "sha256-pd6+VlKB6xa3RtdbnOcuIvL7FcGbT1VCj99iuEvnkwY=";
      };
      sign = {
        name = "Documenso";
        description = "E-signature service for signing documents and contracts";
        icon = "documenso";
        hash = "sha256-yF3AHhE7C2oOhX9cPyOw8BBvryiQs7USFVlJ7dIExBs=";
      };
      subs = {
        name = "Bazarr";
        description = "Subtitle downloader for movies and TV shows";
        icon = "bazarr";
        hash = "sha256-tCd37mIt34Ws4V2+mnDUcaLKNk50XHPqRn2joKdYYWI=";
      };
      sync = {
        name = "Syncthing";
        description = "Peer-to-peer file sync and backup between devices";
        icon = "syncthing";
        hash = "sha256-ZdFDD3UivqBQclmSnwAz18YlOdFHV9fG9bYldOtNotM=";
      };
      torrent = {
        name = "qBittorrent";
        description = "BitTorrent client for downloading and seeding torrents";
        icon = "qbittorrent";
        hash = "sha256-3GpeIIea03tuk2fMyRQ/35A1H0DrCMIAzX0AP/GxwnU=";
      };
      usenet = {
        name = "SABnzbd";
        description = "Usenet downloader for NZB files";
        icon = "sabnzbd";
        hash = "sha256-ElP9YuMQ8sfENgAqeGS4E1ZUog02shd+OQBUL8+El7A=";
      };
    };

    host = subdomain: endpoints.${subdomain}.host or "${subdomain}.${domain}";
    open = subdomain: let
      e = endpoints.${subdomain};
    in "${lib.getExe' pkgs.xdg-utils "xdg-open"} ${e.scheme or "https"}://${host subdomain}${e.path or ""}";

    entry = subdomain: e: let
      id = "homelab-${subdomain}";

      icon = pkgs.fetchurl {
        url = "${icons}/${e.icon}.svg";
        inherit (e) hash;
      };

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
        install -Dm444 ${icon} $out/share/icons/hicolor/scalable/apps/${id}.svg
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

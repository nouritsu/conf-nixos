{
  perSystem = {pkgs, ...}: {
    # only the svgs the homelab launchers use
    packages.dashboard-icons = pkgs.srcOnly {
      stdenv = pkgs.stdenvNoCC;
      pname = "dashboard-icons";
      version = "0-unstable-2026-11-16";
      src = pkgs.fetchFromGitHub {
        owner = "homarr-labs";
        repo = "dashboard-icons";
        rev = "d4b500dc40a8e1043b1581cabb7208892cf35472";
        nonConeMode = true;
        sparseCheckout = map (icon: "/svg/${icon}.svg") [
          "bazarr"
          "beszel"
          "copyparty"
          "documenso"
          "enclosed-light"
          "fritzbox-light"
          "gatus"
          "home-assistant"
          "immich"
          "jellyfin"
          "mousehole-dark"
          "paperless-ngx"
          "pi-hole"
          "prowlarr"
          "qbittorrent"
          "radarr"
          "readarr"
          "sabnzbd"
          "scrutiny-light"
          "sonarr"
          "syncthing"
        ];
        hash = "sha256-Lq/UTpp7LichACSTkoylldTAqUpPSpGszWgcCrBnTj4=";
      };
      passthru.nup = ["--version=branch"];
    };
  };
}

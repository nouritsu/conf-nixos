{
  perSystem = {pkgs, ...}: {
    # only the svgs the homelab launchers use
    packages.dashboard-icons = pkgs.srcOnly {
      stdenv = pkgs.stdenvNoCC;
      pname = "dashboard-icons";
      version = "0-unstable-2026-11-08";
      src = pkgs.fetchFromGitHub {
        owner = "homarr-labs";
        repo = "dashboard-icons";
        rev = "d767d7327db7f8ebd3715b552523f61889eea41c";
        nonConeMode = true;
        sparseCheckout = map (icon: "/svg/${icon}.svg") [
          "bazarr"
          "beszel"
          "copyparty"
          "documenso"
          "enclosed-light"
          "fritzbox-light"
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
        hash = "sha256-TCzo87BnwGsyjAgxQn72rzep7o+yvsP6+/dJg6/tEgQ=";
      };
      passthru.nup = ["--version=branch"];
    };
  };
}

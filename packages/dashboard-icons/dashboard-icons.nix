{
  perSystem = {pkgs, ...}: {
    # only the svgs the homelab launchers use
    packages.dashboard-icons = pkgs.srcOnly {
      stdenv = pkgs.stdenvNoCC;
      pname = "dashboard-icons";
      version = "0-unstable-2026-10-26";
      src = pkgs.fetchFromGitHub {
        owner = "homarr-labs";
        repo = "dashboard-icons";
        rev = "83f32e08257b66fbd971ac8d7645f5b38d52e85d";
        nonConeMode = true;
        sparseCheckout = map (icon: "/svg/${icon}.svg") [
          "bazarr"
          "beszel"
          "copyparty"
          "documenso"
          "enclosed-light"
          "fritzbox-light"
          "home-assistant"
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
        hash = "sha256-sRKykE9D5vmqWrGECTIcMMfmXE2pBuutFOXRObTiLLk=";
      };
      passthru.nup = ["--version=branch"];
    };
  };
}

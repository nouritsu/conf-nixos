# this module should not deal with the backend, only the OCI definition
{config, ...}: {
  virtualisation.oci-containers.containers.gluetun = {
    image = "qmcgaw/gluetun";

    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--device=/dev/net/tun:/dev/net/tun"
    ];

    environment = {
      VPN_SERVICE_PROVIDER = "mullvad";
      VPN_TYPE = "wireguard";

      # WIREGUARD_PRIVATE_KEY = <set by gluetun.env> ;
      WIREGUARD_ADDRESSES = "10.71.99.88/32";
      WIREGUARD_ENDPOINT_PORT = "51820";

      SERVER_COUNTRIES = "Romania";
      SERVER_CITIES = "Bucharest";

      BLOCK_ADS = "on";
      BLOCK_MALICIOUS = "on";
      BLOCK_SURVEILLANCE = "on";
    };

    environmentFiles = [config.sops.templates."gluetun.env".path];
  };
}

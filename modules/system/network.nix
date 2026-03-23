{
  flake.nixosModules = {
    net-base = {pkgs, ...}: {
      networking.networkmanager.enable = true;
      networking.firewall.enable = true;

      # TODO: move this to desktop/packages
      environment.systemPackages = with pkgs; [
        networkmanagerapplet
      ];

      users.users.aneesh.extraGroups = ["networkmanager"];
    };

    net-avahi = {...}: {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    };

    net-dns-pihole = {lib, ...}: {
      networking.nameservers = lib.mkBefore ["192.168.178.168"];
    };

    net-dns-cloudflare = {...}: {
      networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    net-dns-google = {...}: {
      networking.nameservers = [
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };
}

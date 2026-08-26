{
  den.aspects.network = {
    # net-base
    nixos = {pkgs, ...}: {
      networking.networkmanager.enable = true;
      networking.firewall.enable = true;

      environment.systemPackages = [pkgs.networkmanagerapplet];
    };

    provides.avahi.nixos = {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    };

    provides.dns-pihole.nixos = {lib, ...}: {
      networking.nameservers = lib.mkBefore ["192.168.178.168"];
    };
    provides.dns-cloudflare.nixos = {
      networking.nameservers = ["1.1.1.1" "1.0.0.1"];
    };
    provides.dns-google.nixos = {
      networking.nameservers = ["8.8.8.8" "8.8.4.4"];
    };
  };
}

{
  den.aspects.network = {
    nixos = {pkgs, ...}: {
      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.powersave = false;
      networking.firewall.enable = true;

      # nm-connection-editor only; the tray applet is DMS's job
      environment.systemPackages = [pkgs.networkmanagerapplet];
      environment.etc."xdg/autostart/nm-applet.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=NetworkManager Applet
        Hidden=true
      '';
    };

    provides.avahi.nixos = {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    };

    provides.tailscale.nixos = {
      host,
      lib,
      ...
    }: {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "client";

        # the dms widget runs up/down/set as this user
        extraSetFlags = ["--operator=${lib.head (lib.attrNames host.users)}"];
      };
    };

    provides.dns-pihole.nixos = {lib, ...}: {
      networking.nameservers = lib.mkBefore ["192.168.178.128"];
    };
    provides.dns-cloudflare.nixos = {
      networking.nameservers = ["1.1.1.1" "1.0.0.1"];
    };
    provides.dns-google.nixos = {
      networking.nameservers = ["8.8.8.8" "8.8.4.4"];
    };
  };
}

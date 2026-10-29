{
  den.aspects.network = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.powersave = false;
      networking.firewall.enable = true;

      # boot and the greeter don't wait for a connection
      systemd.services.NetworkManager-wait-online.enable = false;

      # nm-connection-editor only; the tray applet is Dux's job
      environment.systemPackages = [pkgs.networkmanagerapplet];
      environment.etc."xdg/autostart/nm-applet.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=NetworkManager Applet
        Hidden=true
      '';

      which-key'.menu.s.submenu.n = {
        desc = "Network editor";
        icon = "f0317";
        cmd = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
        app-id = "nm-connection-editor";
      };
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

        # the dux widget runs up/down/set as this user
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

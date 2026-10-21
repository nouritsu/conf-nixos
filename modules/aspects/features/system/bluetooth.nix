{
  den.aspects.bluetooth.nixos = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    # blueman-manager only; the tray applet is DMS's job
    services.blueman.enable = true;
    environment.etc."xdg/autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Blueman Applet
      Hidden=true
    '';

    which-key'.menu.s.submenu.b = {
      desc = "Blueman";
      icon = "f00af";
      cmd = "blueman-manager";
      app-id = "blueman";
    };
  };
}

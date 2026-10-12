{
  den.aspects.bluetooth.nixos = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
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
  };
}

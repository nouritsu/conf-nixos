{
  hardware.opentabletdriver.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0666"
  '';
}

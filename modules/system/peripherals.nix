{self, ...}: {
  flake.nixosModules = {
    peripheral-uinput = {...}: {
      hardware.uinput.enable = true;
      users.users.aneesh.extraGroups = ["input"];
    };

    peripheral-keyboard = {
      console.keyMap = "us";
      services.xserver.xkb.layout = "eu";
    };

    peripheral-tablet = {...}: {
      imports = [
        self.nixosModules.peripheral-uinput
      ];

      hardware.opentabletdriver.enable = true;

      services.udev.extraRules = ''
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0660", GROUP="input"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0660", GROUP="input"
      '';
    };
  };
}

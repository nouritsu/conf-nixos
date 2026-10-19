{
  den.aspects.plymouth.nixos = {self', ...}: {
    boot.plymouth = {
      enable = true;
      theme = "snowflake";
      themePackages = [self'.packages.plymouth-snowflake];
    };

    # its port also sets boot.plymouth.theme
    catppuccin.plymouth.enable = false;

    # no kernel or udev text over the splash
    boot.consoleLogLevel = 3;
    boot.kernelParams = ["quiet" "udev.log_level=3" "rd.udev.log_level=3"];
  };
}

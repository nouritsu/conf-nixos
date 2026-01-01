{...}: {
  imports = [
    ./hwconf.nix
  ];

  my = {
    system = {
      arch = "x86_64-linux";
      kind = "desktop";
      hostname = "pc";
      graphics = "nvidia";
    };

    boot = {
      loader = "grub";
      multi = true;
    };

    user = {
      alias = "aneesh";
      name = "Aneesh Bhave";
      email = "aneesh1701@gmail.com";
    };
  };

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "25.11";
}

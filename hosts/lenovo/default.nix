{...}: {
  imports = [
    ./hwconf.nix
  ];

  my = {
    system = {
      arch = "x86_64-linux";
      kind = "laptop";
      hostname = "lenovo";
      graphics = "intel";
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

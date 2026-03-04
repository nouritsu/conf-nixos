{
  flake.nixosModules.user-aneesh = {...}: {
    users.users.aneesh = {
      isNormalUser = true;
      description = "Aneesh Bhave";
      extraGroups = ["wheel"];
    };
  };
}

{
  inputs,
  self,
  ...
}: {
  flake.homeModules.home-manager-base = {...}: {
    programs.home-manager.enable = true;

    home = {
      username = "aneesh";
      homeDirectory = "/home/aneesh";
      stateVersion = "25.11";
    };

    gtk.gtk4.theme = null;

    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  flake.nixosModules.home-manager-integration = {...}: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    my.hmUsers = ["aneesh"];

    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      backupFileExtension = "backup";
      users.aneesh.imports = [
        self.homeModules.home-manager-base
      ];
    };
  };
}

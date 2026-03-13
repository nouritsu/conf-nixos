{
  inputs,
  self,
  ...
}: {
  flake.homeModules.home-manager-base = {osConfig, ...}: {
    programs.home-manager.enable = true;

    home = {
      username = osConfig.my.user.alias;
      homeDirectory = "/home/${osConfig.my.user.alias}";
      stateVersion = "25.11";
    };

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
        # ../home.h.nix
      ];
    };
  };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    home-manager,
    stylix,
    ...
  }: {
    nixosConfigurations = {
      wsl = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/wsl.nix
          ./modules/core
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${specialArgs.user.alias}.imports = [./home.nix];
              extraSpecialArgs = specialArgs;
            };
          }
          stylix.nixosModules.stylix
        ];

        specialArgs = {
          user = {
            name = "Aneesh Bhave";
            email = "aneesh1701@gmail.com";
            alias = "aneesh";
          };

          hostname = "wsl";

          gui = false;
        };
      };

      lenovo = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/laptop/configuration.nix
          ./modules/core
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${specialArgs.user.alias}.imports = [./home.nix];
              extraSpecialArgs = specialArgs;
            };
          }
          stylix.nixosModules.stylix
        ];

        specialArgs = {
          user = {
            name = "Aneesh Bhave";
            email = "aneesh1701@gmail.com";
            alias = "aneesh";
          };

          hostname = "lenovo";

          gui = true;
        };
      };
    };
  };
}

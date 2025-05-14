{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:helix-editor/helix";

    yazi.url = "github:sxyazi/yazi";

    cachix.url = "github:cachix/cachix";
  };

  outputs = {...} @ inputs: let
  in {
    nixosConfigurations = {
      wsl = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        modules = [
          inputs.nixos-wsl.nixosModules.default
          ./wsl.nix

          ./modules/core

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${specialArgs.user.alias}.imports = [./home.nix];
              extraSpecialArgs = specialArgs;
            };
          }

          ./cachix.nix
        ];

        specialArgs = {
          inherit inputs;

          user = {
            name = "Aneesh Bhave";
            email = "aneesh1701@gmail.com";
            alias = "aneesh";
          };
          hostname = "wsl";
        };
      };
    };
  };
}

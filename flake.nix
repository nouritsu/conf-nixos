{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nouritsu/home-manager/helix_extra_config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";

    stylix.url = "github:danth/stylix";

    helix.url = "github:helix-editor/helix/master";

    walker.url = "github:abenz1267/walker";
  };

  outputs = {...} @ inputs: let
    user = {
      name = "Aneesh Bhave";
      email = "aneesh1701@gmail.com";
      alias = "aneesh";
    };
    gui = true;
    wsl = false;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      wsl = inputs.nixpkgs.lib.nixosSystem rec {
        inherit system;

        modules = [
          inputs.nixos-wsl.nixosModules.default
          ./hosts/wsl.nix
          ./modules/core
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${specialArgs.user.alias}.imports = [./home.nix];
              extraSpecialArgs = specialArgs;
            };
          }
        ];

        specialArgs = {
          inherit inputs user;
          hostname = "wsl";
          gui = false;
          wsl = true;
        };
      };

      lenovo = inputs.nixpkgs.lib.nixosSystem rec {
        inherit system;

        modules = [
          ./hosts/laptop/configuration.nix
          ./modules/core
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${specialArgs.user.alias}.imports = [./home.nix];
              extraSpecialArgs = specialArgs;
            };
          }
          inputs.stylix.nixosModules.stylix
        ];

        specialArgs = {
          inherit inputs user gui wsl;
          hostname = "lenovo";
        };
      };
    };
  };
}

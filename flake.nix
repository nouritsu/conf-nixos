{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";

    stylix.url = "github:danth/stylix";

    helix.url = "github:helix-editor/helix/master";

    yazi.url = "github:sxyazi/yazi";

    walker.url = "github:abenz1267/walker";

    cachix.url = "github:cachix/cachix";
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
          ./cachix.nix
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
          ./hosts/lenovo/configuration.nix
          ./modules/core
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${specialArgs.user.alias}.imports = [./home.nix];
              extraSpecialArgs = specialArgs;
            };
          }
          inputs.stylix.nixosModules.stylix
          ./cachix.nix
        ];

        specialArgs = {
          inherit inputs user gui wsl;
          hostname = "lenovo";
        };
      };
    };
  };
}

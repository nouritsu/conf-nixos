{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:helix-editor/helix/master";

    yazi.url = "github:sxyazi/yazi";

    walker.url = "github:abenz1267/walker";

    wezterm.url = "github:wezterm/wezterm?dir=nix";

    cachix.url = "github:cachix/cachix";
  };

  outputs = {...} @ inputs: let
    user = {
      name = "Aneesh Bhave";
      email = "aneesh1701@gmail.com";
      alias = "aneesh";
    };
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      lenovo = inputs.nixpkgs.lib.nixosSystem rec {
        modules = [
          ./hosts/lenovo/configuration.nix
          ./modules/core
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${specialArgs.user.alias}.imports = [./home.nix];
              extraSpecialArgs = specialArgs;
              backupFileExtension = "backup";
            };
          }
          inputs.stylix.nixosModules.stylix
          ./cachix.nix
        ];

        specialArgs = {
          inherit inputs user system;
          hostname = "lenovo";
        };
      };
    };
  };
}

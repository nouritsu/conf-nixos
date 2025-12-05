{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Core
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cachix.url = "github:cachix/cachix";

    # Applications
    helix.url = "github:helix-editor/helix/master";
    hyprcwd-rs.url = "github:JonnieCache/hyprcwd-rs";
    hyprland.url = "github:hyprwm/hyprland";
    walker.url = "github:abenz1267/walker";
    wezterm.url = "github:wezterm/wezterm?dir=nix";
    yazi.url = "github:sxyazi/yazi";
  };

  outputs = {...} @ inputs: let
    usrconf = {
      user = {
        name = "Aneesh Bhave";
        email = "aneesh1701@gmail.com";
        alias = "aneesh";
      };
      hostname = ""; # set by specific configs
      system = "x86_64-linux";
    };
  in {
    nixosConfigurations = {
      lenovo = inputs.nixpkgs.lib.nixosSystem rec {
        modules = [
          ./hosts/lenovo/configuration.nix # host
          ./modules

          # Extra modules
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${usrconf.user.alias}.imports = [./modules/home.h.nix];
              extraSpecialArgs = specialArgs;
              backupFileExtension = "backup"; # prevents some weird error somehow
            };
          }
        ];

        specialArgs = {
          inherit inputs;
          usrconf = usrconf // {hostname = "lenovo";};
        };
      };
    };
  };
}

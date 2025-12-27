{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Core
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cachix.url = "github:cachix/cachix";

    # Themeing
    catppuccin.url = "github:catppuccin/nix";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Software / Firmware
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    helix.url = "github:helix-editor/helix/master";
    hyprcwd-rs.url = "github:JonnieCache/hyprcwd-rs";
    hyprland.url = "github:hyprwm/hyprland";
    hyprlock.url = "github:hyprwm/hyprlock";
    walker.url = "github:abenz1267/walker";
    waybar.url = "github:xav-ie/Waybar/fix-cava-nix-sync";
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
      nvidia = false;
      touchpad = false;
    };
  in {
    nixosConfigurations = {
      pc = inputs.nixpkgs.lib.nixosSystem rec {
        modules = [
          ./hosts/pc/configuration.nix # host
          ./modules

          # Extra modules
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.home-manager
          inputs.catppuccin.nixosModules.catppuccin
          {
            home-manager = {
              users.${usrconf.user.alias}.imports = [
                ./modules/home.h.nix
                inputs.catppuccin.homeModules.catppuccin
              ];
              extraSpecialArgs = specialArgs;
              backupFileExtension = "backup"; # prevents some weird error somehow
            };
          }
        ];

        specialArgs = {
          inherit inputs;
          usrconf =
            usrconf
            // {
              hostname = "pc";
              nvidia = true;
            };
        };
      };

      lenovo = inputs.nixpkgs.lib.nixosSystem rec {
        modules = [
          ./hosts/lenovo/configuration.nix # host
          ./modules

          # Extra modules
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.home-manager
          inputs.catppuccin.nixosModules.catppuccin
          {
            home-manager = {
              users.${usrconf.user.alias}.imports = [
                ./modules/home.h.nix
                inputs.catppuccin.homeModules.catppuccin
              ];
              extraSpecialArgs = specialArgs;
              backupFileExtension = "backup"; # prevents some weird error somehow
            };
          }
        ];

        specialArgs = {
          inherit inputs;
          usrconf =
            usrconf
            // {
              hostname = "lenovo";
              touchpad = true;
            };
        };
      };
    };
  };
}

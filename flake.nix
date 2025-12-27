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
    common_modules = with inputs; [
      ./modules

      # from inputs
      home-manager.nixosModules.home-manager
      stylix.nixosModules.stylix
      catppuccin.nixosModules.catppuccin

      ({config, ...}: {
        home-manager = {
          extraSpecialArgs = {inherit inputs;};
          backupFileExtension = "backup"; # prevents some weird error somehow
          users.${config.my.user.alias}.imports = [
            ./modules/home.h.nix
            inputs.catppuccin.homeModules.catppuccin
          ];
        };
      })
    ];

    mk_host = host_mod:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [./options.nix host_mod] ++ common_modules;
        specialArgs = {inherit inputs;};
      };
  in {
    nixosConfigurations = {
      pc = mk_host ./hosts/pc;
      lenovo = mk_host ./hosts/lenovo;
    };
  };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Core
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cachix.url = "github:cachix/cachix";

    # Theming
    catppuccin.url = "github:catppuccin/nix";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Software / Firmware
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    helix.url = "github:nouritsu/conf-helix";
    hyprcwd-rs.url = "github:JonnieCache/hyprcwd-rs";
    hyprland.url = "github:hyprwm/hyprland";
    hyprlock.url = "github:hyprwm/hyprlock";
    wezterm.url = "github:wezterm/wezterm?dir=nix";
    dms.url = "github:AvengeMedia/DankMaterialShell";
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    yazi.url = "github:sxyazi/yazi";
    batfetch = {
      url = "github:ashish-kus/batfetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        ({lib, ...}: {
          options.flake.homeModules = lib.mkOption {
            type = with lib.types; lazyAttrsOf raw;
            default = {};
          };
        })
        (import-tree ./modules/system)
        (import-tree ./modules/theme)
        (import-tree ./modules/applications)
        ./hosts/pc.nix
      ];
    };
}

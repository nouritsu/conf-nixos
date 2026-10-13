{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Den framework
    den.url = "github:denful/den";

    # Core
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    catppuccin.url = "github:catppuccin/nix";
    nix-colors.url = "github:misterio77/nix-colors";
    qtengine = {
      url = "github:kossLAN/qtengine";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Software / Firmware
    # no follows: these are prebuilt in their own binary caches
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    lanzaboote.url = "github:nix-community/lanzaboote";
    helix.url = "github:helix-editor/helix/master";
    yazi.url = "github:sxyazi/yazi";

    # follows: niri dlopens the system GL drivers, so its glibc must match
    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pinned: its nix packaging has broken on releases, bump by hand once a new one builds
    # nixpkgs-bun stays its own: the bun deps hash depends on that exact bun
    millennium = {
      url = "github:SteamClientHomebrew/Millennium/0d22d4330995fff5a6dcb0b255dfb48f96f64972?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    batfetch = {
      url = "github:ashish-kus/batfetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        (import-tree ./modules)
        (import-tree ./packages)
      ];
    };
}

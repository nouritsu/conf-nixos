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
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Software / Firmware
    #
    # The inputs below deliberately keep their own nixpkgs. Each ships a
    # prebuilt binary from a cache this system trusts, so a follows would change
    # the derivation hash and turn every cache hit into a local build:
    #
    #   cachyos-kernel  attic.xuyh0120.win/lantian  the whole kernel
    #   helix           helix.cachix.org            inputs'.helix.packages.helix
    #   yazi            yazi.cachix.org             inputs'.yazi.packages.default
    #   niri            niri.cachix.org             niri.packages.<sys>.niri-unstable
    #   lanzaboote      nix-community.cachix.org    reads as a pure module but is
    #                     not: nixosModules.lanzaboote pins boot.lanzaboote.package
    #                     to self.packages.<sys>.lzbt, a Rust build against its own
    #                     nixpkgs + crane + rust-overlay, on pc's Secure Boot path.
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    lanzaboote.url = "github:nix-community/lanzaboote";
    helix.url = "github:helix-editor/helix/master";
    niri.url = "github:sodiboo/niri-flake";
    yazi.url = "github:sxyazi/yazi";

    # dms kept its own nixpkgs for a prebuilt dms-shell on cache.garnix.io,
    # which is gone -- the name stopped resolving. It builds here whichever
    # nixpkgs it gets, and on its own one it dragged a second Qt, ffmpeg,
    # python and glibc into the closure: following ours took 1.5 GiB off pc.
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Its nixpkgs was locked to c043004d -- the rev this flake already pins,
    # just fetched as a tarball rather than via github, so the lock carried a
    # byte-identical duplicate. mkSpicetify takes our pkgs anyway.
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixosModules.default is a bare path whose module does
    # `import ./default.nix { inherit pkgs; }`; its own nixpkgs only ever fed
    # the flake's devShell and formatter.
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    batfetch = {
      url = "github:ashish-kus/batfetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixosModules.sops is a bare path and sops.package defaults to
    # (pkgs.callPackage ../.. {}).sops-install-secrets -- built from our pkgs,
    # never from sops-nix's own. Following changes no derivation.
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

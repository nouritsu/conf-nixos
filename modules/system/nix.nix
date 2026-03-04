{
  flake.nixosModules = {
    nixpkgs-base = {lib, ...}: let
      local_pkg = pkg: ../pkgs/${pkg}/package.nix;
    in {
      nixpkgs.overlays = [
        # Local pkgs/pkg/package.nix
        (
          final: _:
            lib.genAttrs [
              "ifetch"
              "mfetch"
            ] (pkg: final.callPackage (local_pkg pkg) {})
        )
      ];
    };

    nixpkgs-unfree = {...}: {
      nixpkgs.config.allowUnfree = true;
    };

    nix-base = {...}: {
      programs.nix-ld.enable = true;
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nix.settings.trusted-users = ["root" "@wheel"];
      nix.optimise = {
        automatic = true;
        dates = ["*-*-1/3 21:00"]; # every third day at 21:00
      };
    };

    nix-cache = {...}: {
      # TODO: move to per application
      nix.settings = {
        extra-substituters = [
          "https://attic.xuyh0120.win/lantian"
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://helix.cachix.org"
          "https://yazi.cachix.org"
          "https://wezterm.cachix.org"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
          "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
          "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        ];
      };
    };

    nix-nh = {...}: {
      programs.nh = {
        enable = true;
        flake = "/home/aneesh/.config/nixos";

        clean = {
          enable = true;
          extraArgs = "--keep 5 --keep-since 7d";
        };
      };
    };
  };
}

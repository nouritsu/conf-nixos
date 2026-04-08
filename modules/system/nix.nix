{inputs, ...}: {
  flake.nixosModules = {
    nixpkgs-unfree = {...}: {
      nixpkgs.config.allowUnfree = true;
    };

    nix-base = {...}: {
      imports = [
        inputs.determinate.nixosModules.default
        inputs.nix-index-database.nixosModules.default
      ];

      programs.nix-ld.enable = true;
      nix.settings.trusted-users = ["root" "@wheel"];
      programs.nix-index-database.comma.enable = true;
    };

    # TODO: move to per application
    nix-cache = {...}: {
      nix.settings = {
        extra-substituters = [
          "https://attic.xuyh0120.win/lantian"
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
          "https://yazi.cachix.org"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
        ];
      };
    };
  };
}

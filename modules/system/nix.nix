{inputs, ...}: {
  flake.nixosModules = {
    nixpkgs-unfree = {...}: {
      nixpkgs.config.allowUnfree = true;
    };

    nix-base = {...}: {
      imports = [
        inputs.determinate.nixosModules.default
      ];
      programs.nix-ld.enable = true;
      nix.settings.trusted-users = ["root" "@wheel"];
      nix.settings.eval-cores = 0;
    };

    # TODO: move to per application
    nix-cache = {...}: {
      nix.settings = {
        extra-substituters = [
          "https://attic.xuyh0120.win/lantian"
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://yazi.cachix.org"
          "https://wezterm.cachix.org"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
          "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        ];
      };
    };
  };
}

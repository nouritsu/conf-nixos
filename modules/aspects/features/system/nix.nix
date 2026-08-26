{inputs, ...}: {
  den.aspects.nix.nixos = {
    imports = [
      inputs.determinate.nixosModules.default
      inputs.nix-index-database.nixosModules.default
    ];

    programs.nix-ld.enable = true;
    programs.nix-index-database.comma.enable = true;

    programs.nh = {
      enable = true;
      flake = "/home/aneesh/.config/nixos";

      clean.enable = true;
      clean.extraArgs = "--keep 5 --keep-since 7d";
    };

    programs.fish.shellAliases.conf = "$EDITOR $NH_FLAKE";
    programs.fish.shellAbbrs = {
      nhrb = "nh os boot";
      nhrs = "nh os switch";
      nhrt = "nh os test";
      nhca = "nh clean all";
      nhs = "nh search";
    };

    nix.settings.trusted-users = ["root" "@wheel"];

    # TODO: move to per app
    nix.settings.extra-substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
      "https://yazi.cachix.org"
    ];
    nix.settings.trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    ];
  };
}

{
  imports = [
    ./cache.nix
    ./maintainence.nix
    ./nh.nix
    ./overlays.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  programs.nix-ld.enable = true;
}

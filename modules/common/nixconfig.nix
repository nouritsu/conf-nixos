/*
Config for: Nix, Nixpkgs, Cachix
*/
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.cachyos-kernel.overlays.pinned
      (final: _: {
        gpu-usage-waybar = final.callPackage ../../pkgs/gpu-usage-waybar/package.nix {};
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    cachix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://attic.xuyh0120.win/lantian"
      # "https://cache.garnix.io"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://helix.cachix.org"
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
      "https://yazi.cachix.org"
      "https://wezterm.cachix.org"
    ];
    trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
    ];
  };
}

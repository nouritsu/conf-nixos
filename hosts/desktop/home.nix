{ config, pkgs, ... }: {
  home.username = "nouritsu";
  home.homeDirectory = "/home/nouritsu";

  home.sessionVariables = { FLAKE = "/home/nouritsu/nix/"; };

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}

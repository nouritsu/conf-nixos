{ config, pkgs, ... }: {
  home.username = "nouritsu";
  home.homeDirectory = "/home/nouritsu";

  home.sessionVariables = { FLAKE = "/home/nouritsu/nix/"; };

  programs.git = {
    enable = true;
    userName = "nouritsu";
    userEmail = "aneesh1701@gmail.com";
  };

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}

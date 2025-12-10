{usrconf, ...}: {
  imports = [
    # Applications
    ./apps/home.h.nix

    # Environment
    ./de/home.h.nix
    ./te/home.h.nix

    # Theme
    ./theme/home.h.nix
  ];

  home = {
    username = usrconf.user.alias;
    homeDirectory = "/home/${usrconf.user.alias}";
    stateVersion = "25.11";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs.home-manager.enable = true;
}

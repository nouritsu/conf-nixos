{user, ...}: {
  imports = [
    ./modules/home
  ];

  home = {
    username = user.alias;
    homeDirectory = "/home/${user.alias}";
    stateVersion = "24.11";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs.home-manager.enable = true;
}

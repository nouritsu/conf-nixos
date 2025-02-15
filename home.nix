{user, ...}: {
  imports = [
    ./modules/home
  ];

  home = {
    username = user.alias;
    homeDirectory = "/home/${user.alias}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}

{
  user,
  inputs,
  ...
}: {
  imports = [
    ./modules/home
    inputs.walker.homeManagerModules.default
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

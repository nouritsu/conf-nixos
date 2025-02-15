{
  pkgs,
  lib,
  user,
  ...
}: {
  programs.git = {
    enable = true;
    config = {
      user.name = user.name;
      user.email = user.email;
    };
  };

  environment.systemPackages = with pkgs; [
    gh
    lazygit
  ];
}

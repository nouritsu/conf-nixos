{
  user,
  pkgs,
  ...
}: {
  programs = {
    git = {
      enable = true;
      userName = user.name;
      userEmail = user.email;
      delta.enable = true;
    };

    gh.enable = true;
  };
}

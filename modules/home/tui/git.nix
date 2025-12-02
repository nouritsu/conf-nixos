{user, ...}: {
  programs = {
    git = {
      enable = true;
      settings.user = {
        user = user.name;
        email = user.email;
      };
    };
    delta.enable = true;
    gh.enable = true;
  };
}

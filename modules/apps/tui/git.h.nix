{osConfig, ...}: {
  programs = {
    git = {
      enable = true;
      settings.user = {
        user = osConfig.my.user.name;
        email = osConfig.my.user.email;
      };
    };
    delta.enable = true;
    gh.enable = true;
  };
}

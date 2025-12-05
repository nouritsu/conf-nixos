{usrconf, ...}: {
  programs = {
    git = {
      enable = true;
      settings.user = {
        user = usrconf.user.name;
        email = usrconf.user.email;
      };
    };
    delta.enable = true;
    gh.enable = true;
  };
}

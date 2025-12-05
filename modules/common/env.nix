{usrconf, ...}: {
  environment.sessionVariables = {
    NH_FLAKE = "/home/${usrconf.user.alias}/.config/nixos";
  };
}

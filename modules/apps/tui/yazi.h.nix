{
  inputs,
  usrconf,
  ...
}: {
  programs.yazi = {
    enable = true;
    package = inputs.yazi.packages.${usrconf.system}.default;
    enableFishIntegration = true;
    enableBashIntegration = true;
    shellWrapperName = "yazi_wrapper";

    settings = {
      mgr = {
        show_hidden = true;
        linemode = "permissions";
      };
    };
  };
}

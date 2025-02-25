{pkgs, ...}: {
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    server.enable = true;
    settings = {
      mouse.hide-when-typing = "yes";
      csd.border-width = 8;
    };
  };
}

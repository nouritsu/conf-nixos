{pkgs, ...}: {
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    server.enable = true;
    settings = {
      pad = "8x8";
      mouse.hide-when-typing = "yes";
    };
  };
}

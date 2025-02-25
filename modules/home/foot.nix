{pkgs, ...}: {
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    server.enable = true;
    settings = {
      main.pad = "8x8";
      mouse.hide-when-typing = "yes";
    };
  };
}

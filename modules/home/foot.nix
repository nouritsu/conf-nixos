{pkgs, ...}: {
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    server.enable = true;
    settings = {
    };
  };
}

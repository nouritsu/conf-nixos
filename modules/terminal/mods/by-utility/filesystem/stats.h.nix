{pkgs, ...}: let
  dust = "${pkgs.dust}/bin/dust";
  tokei = "${pkgs.tokei}/bin/tokei";
in {
  home.packages = [
    pkgs.dust
  ];

  home.shellAliases = {
    du = dust;
    count-code = tokei;
  };
}

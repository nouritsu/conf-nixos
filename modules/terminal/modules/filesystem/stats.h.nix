{
  lib,
  pkgs,
  ...
}: let
  dust = lib.getExe pkgs.dust;
  tokei = lib.getExe pkgs.tokei;
in {
  home.packages = [
    pkgs.dust
  ];

  home.shellAliases = {
    du = dust;
    count-code = tokei;
  };
}

{
  lib,
  pkgs,
  ...
}: let
  harper-ls = lib.getExe pkgs.harper;
in {
  home.packages = [
    pkgs.harper
  ];

  programs.helix.languages = {
    language-server = {
      harper-ls = {
        command = harper-ls;
        args = ["--stdio"];
        config.harper-ls = {
          dialect = "British";
        };
      };
    };
  };
}

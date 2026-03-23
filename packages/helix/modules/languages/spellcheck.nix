{
  flake.nixosModules.whelix-spellcheck = {
    lib,
    pkgs,
    ...
  }: let
    harper-ls = lib.getExe pkgs.harper;
  in {
    languages.language-server = {
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

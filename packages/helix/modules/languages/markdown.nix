{
  flake.nixosModules.whelix-lsp-markdown = {
    lib,
    pkgs,
    ...
  }: let
    marksman = lib.getExe pkgs.marksman;
  in {
    languages.language-server.marksman.command = marksman;

    languages.language = [
      {
        name = "markdown";
        language-servers = ["marksman" "harper-ls"];
      }
    ];
  };
}

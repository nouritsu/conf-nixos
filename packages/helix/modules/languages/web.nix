{
  flake.nixosModules.whelix-lsp-web = {
    lib,
    pkgs,
    ...
  }: let
    extracted = name: lib.getExe' pkgs.vscode-langservers-extracted "vscode-${name}-language-server";
  in {
    languages.language-server = {
      vscode-json-language-server.command = extracted "json";
      vscode-css-language-server.command = extracted "css";
      vscode-html-language-server.command = extracted "html";
    };

    languages.language = [
      {
        name = "html";
        language-servers = ["vscode-html-language-server" "scls"];
      }
      {
        name = "css";
        language-servers = ["vscode-css-language-server" "scls"];
      }
      {
        name = "scss";
        language-servers = ["vscode-css-language-server" "scls"];
      }
    ];
  };
}

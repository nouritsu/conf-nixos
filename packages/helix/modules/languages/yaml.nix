{
  flake.nixosModules.whelix-lsp-yaml = {
    lib,
    pkgs,
    ...
  }: {
    languages.language-server.yaml-language-server.command = lib.getExe pkgs.yaml-language-server;

    languages.language = [
      {
        name = "yaml";
        language-servers = ["yaml-language-server" "scls"];
      }
    ];
  };
}

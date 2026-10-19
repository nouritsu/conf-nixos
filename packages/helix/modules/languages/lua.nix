{
  flake.nixosModules.whelix-lsp-lua = {
    lib,
    pkgs,
    ...
  }: {
    languages.language-server.lua-language-server.command = lib.getExe pkgs.lua-language-server;

    languages.language = [
      {
        name = "lua";
        language-servers = ["lua-language-server" "scls"];
      }
    ];
  };
}

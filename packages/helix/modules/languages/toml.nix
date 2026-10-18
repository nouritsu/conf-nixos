{
  flake.nixosModules.whelix-lsp-toml = {
    lib,
    pkgs,
    ...
  }: {
    languages.language-server.taplo.command = lib.getExe pkgs.taplo;
  };
}

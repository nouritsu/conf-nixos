{
  flake.nixosModules.whelix-lsp-qml = {
    lib,
    pkgs,
    ...
  }: {
    languages.language-server.qmlls.command = lib.getExe' pkgs.kdePackages.qtdeclarative "qmlls";
  };
}

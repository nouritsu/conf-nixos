{
  flake.nixosModules.whelix-lsp-qml = {onDemand, ...}: {
    languages.language-server.qmlls.command = onDemand "kdePackages.qtdeclarative" "qmlls";
  };
}

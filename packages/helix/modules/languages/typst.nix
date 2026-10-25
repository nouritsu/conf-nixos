{
  flake.nixosModules.whelix-lsp-typst = {
    lib,
    pkgs,
    onDemand,
    ...
  }: let
    tinymist = onDemand "tinymist" "tinymist";
    typstyle = lib.getExe pkgs.typstyle;
  in {
    languages.language-server = {
      tinymist = {
        command = tinymist;
        config = {
          exportPdf = "onSave";
          formatterMode = "typstyle";
        };
      };
    };

    languages.language = [
      {
        name = "typst";
        language-servers = ["tinymist" "harper-ls"];
        formatter = {
          command = typstyle;
        };
        auto-format = true;
      }
    ];
  };
}

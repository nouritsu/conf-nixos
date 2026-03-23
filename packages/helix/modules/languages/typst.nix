{
  flake.nixosModules.whelix-lsp-typst = {
    lib,
    pkgs,
    ...
  }: let
    tinymist = lib.getExe pkgs.tinymist;
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
        language-servers = ["tinymist"];
        formatter = {
          command = typstyle;
        };
        auto-format = true;
      }
    ];
  };
}

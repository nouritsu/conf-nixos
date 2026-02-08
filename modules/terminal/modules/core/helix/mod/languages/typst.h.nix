{
  lib,
  pkgs,
  ...
}: let
  tinymist = lib.getExe pkgs.tinymist;
  typstyle = lib.getExe pkgs.typstyle;
in {
  programs.helix.languages = {
    language-server = {
      tinymist = {
        command = tinymist;
        config = {
          exportPdf = "onSave";
          formatterMode = "typstyle";
        };
      };
    };
    language = [
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

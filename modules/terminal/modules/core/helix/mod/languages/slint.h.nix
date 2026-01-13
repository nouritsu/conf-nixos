{
  lib,
  pkgs,
  ...
}: let
  slint-lsp = lib.getExe pkgs.slint-lsp;
in {
  programs.helix.languages = {
    language-server = {
      slint-lsp.command = slint-lsp;
    };

    language = [
      {
        name = "slint";
        scope = "source.slint";
        injection-regex = "slint";
        file-types = ["slint"];
        language-servers = ["slint-lsp"];
        auto-format = true;

        comment-token = "//";
        block-comment-tokens = {
          start = "/*";
          end = "*/";
        };

        indent = {
          tab-width = 4;
          unit = "    ";
        };
      }
    ];
  };
}

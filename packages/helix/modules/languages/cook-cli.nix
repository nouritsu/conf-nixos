{
  flake.nixosModules.whelix-lsp-cook-cli = {...}: {
    languages.language = [
      {
        name = "cooklang";
        language-id = "markdown";
        scope = "source.cooklang";
        injection-regex = "cook(lang)?";
        file-types = ["cook"];
        roots = ["config"];

        language-servers = [];

        auto-format = false;

        comment-tokens = ["--"];
        block-comment-tokens = [
          {
            start = "[-";
            end = "-]";
          }
        ];

        auto-pairs = {
          "(" = ")";
          "{" = "}";
          "[" = "]";
          "\"" = "\"";
        };

        indent = {
          tab-width = 2;
          unit = "  ";
        };
      }
    ];
  };
}

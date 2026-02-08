{
  programs.helix.languages = {
    language = [
      {
        name = "cooklang";
        language-id = "markdown";
        scope = "source.cooklang";
        injection-regex = "cook(lang)?";
        file-types = ["cook"];
        roots = ["config"];

        language-servers = [
          "harper-ls"
        ];

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

    grammar = [
      {
        name = "cooklang";
        source = {
          git = "https://github.com/addcninblue/tree-sitter-cooklang";
          rev = "4ebe237c1cf64cf3826fc249e9ec0988fe07e58e";
        };
      }
    ];
  };
}

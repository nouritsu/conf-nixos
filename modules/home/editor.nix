{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.helix = {
    enable = true;
    settings = {
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "block";
      };
    };

    languages.language = let
      prettier = "${pkgs.nodePackages_latest.prettier}/bin/prettier";
    in [
      {
        name = "rust";
        auto-format = true;
        formatter.command = "${pkgs.rustfmt}/bin/rustfmt";
      }

      {
        name = "c";
        auto-format = true;
        formatter.command = "${pkgs.clang-tools}/bin/clang-format";
      }

      {
        name = "cpp";
        auto-format = true;
        formatter.command = "${pkgs.clang-tools}/bin/clang-format";
      }

      {
        name = "python";
        auto-format = true;
        formatter.command = "${pkgs.black}/bin/black";
      }

      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.alejandra}/bin/alejandra";
      }

      {
        name = "go";
        auto-format = true;
        formatter.command = "${pkgs.go}/bin/go fmt";
      }

      {
        name = "javascript";
        auto-format = true;
        formatter.command = prettier;
      }

      {
        name = "typescript";
        auto-format = true;
        formatter.command = prettier;
      }

      {
        name = "json";
        auto-format = true;
        formatter.command = prettier;
      }
    ];
  };
}

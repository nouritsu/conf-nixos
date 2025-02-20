{pkgs, ...}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        line-number = "relative";
        mouse = false; # change once comfortable
        cursor-shape.insert = "bar";
        bufferline = "always";
        color-modes = true;

        cursorline = true;

        inline-diagnostics = {
          cursor-line = "warning";
        };

        end-of-line-diagnostics = "hint";

        indent-guides = {
          render = true;
          character = "┆";
          skip-levels = 1;
        };

        statusline = {
          left = ["mode" "selections" "primary-selection-length" "separator" "position" "position-percentage"];

          center = [
            "file-encoding"
            "file-type"
            "file-line-ending"

            "separator"
            "file-name"
            "read-only-indicator"
            "separator"

            "spacer"
            "version-control"
            "file-modification-indicator"
          ];

          right = ["spinner" "diagnostics" "separator" "workspace-diagnostics"];

          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
      };

      keys = {
        normal = {
          # New
          esc = ["collapse_selection" "keep_primary_selection"];
          ret = "goto_word";
          D = ["ensure_selections_forward" "extend_to_line_end"];
          C-q = ":buffer-close";

          # Redefinitions
          x = "extend_line";
          a = ["append_mode" "collapse_selection"];

          # External Integrations
          C-g = [":new" ":insert-output lazygit" ":buffer-close!" ":redraw"];

          # Arrow Keys
          left = "goto_previous_buffer";
          right = "goto_next_buffer";
          down = "goto_prev_diag";
          up = "goto_next_diag";

          # Add Yank minor mode for diags, code, sels
          # Change goto minor mode for next funcs files etc.
        };

        select = {
          x = "extend_line";
        };
      };
    };

    languages = {
      language = [
        {
          name = "bash";
          auto-format = true;
          formatter.command = "${pkgs.beautysh}/bin/beautysh";
          shebangs = ["sh" "bash" "zsh"];
          language-servers = [
            {
              name = "bash-language-server";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "c";
          auto-format = true;
          language-servers = [
            {
              name = "clangd";
            }
          ];
        }
        {
          name = "cpp";
          auto-format = true;
          language-servers = [
            {
              name = "clangd";
            }
          ];
        }
        {
          name = "cmake";
          auto-format = true;
          formatter.command = "${pkgs.cmake-format}/bin/cmake-format";
          language-servers = [
            {
              name = "cmake-language-server";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "dart";
          auto-format = true;
          language-servers = [
            {
              name = "dart";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "dockerfile";
          auto-format = true;
          language-servers = [
            {
              name = "dockerfile-language-server";
            }
          ];
        }
        {
          name = "dot";
          auto-format = true;
          language-servers = [
            {
              name = "dot-language-server";
            }
          ];
        }
        {
          name = "fish";
          auto-format = true;
          language-servers = [
            {
              name = "fish-lsp";
            }
          ];
        }
        {
          name = "gdscript";
          auto-format = true;
        }
        {
          name = "go";
          auto-format = true;
          formatter.command = "${pkgs.go}/bin/gofmt";
          language-servers = [
            {
              name = "gopls";
            }
          ];
        }
        {
          name = "haskell";
          auto-format = true;
          language-servers = [
            {
              name = "haskell-language-server";
            }
          ];
        }
        {
          name = "java";
          auto-format = true;
          formatter.command = "${pkgs.google-java-format}/bin/google-java-format";
          language-servers = [
            {
              name = "jdtls";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "javascript";
          auto-format = true;
          language-servers = [
            {
              name = "typescript-language-server";
            }
          ];
        }
        {
          name = "json";
          auto-format = true;
          language-servers = [
            {
              name = "vscode-json-languageserver";
            }
          ];
        }
        {
          name = "kotlin";
          auto-format = true;
          formatter.command = "${pkgs.ktfmt}/bin/ktfmt";
          language-servers = [
            {
              name = "kotlin-language-server";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "latex";
          auto-format = true;
          language-servers = [
            {
              name = "texlab";
            }
          ];
        }
        {
          name = "lua";
          auto-format = true;
          formatter.command = "${pkgs.stylua}/bin/stylua";
          language-servers = [
            {
              name = "lua-language-server";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "markdown";
          auto-format = true;
          formatter.command = "${pkgs.markdownlint-cli}/bin/markdownlint";
          language-servers = [
            {
              name = "marksman";
            }
          ];
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.alejandra}/bin/alejandra";
          language-servers = [
            {
              name = "nixd";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "glsl";
          auto-format = true;
          language-servers = [
            {
              name = "glsl_analyzer";
            }
          ];
        }
        {
          name = "perl";
          auto-format = true;
          formatter.command = "${pkgs.perl540Packages.PerlTidy}/bin/perltidy";
          language-servers = [
            {
              name = "perlnavigator";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "prolog";
          auto-format = true;
          language-servers = [
            {
              name = "swipl";
            }
          ];
        }
        {
          name = "python";
          auto-format = true;
          formatter.command = "${pkgs.black}/bin/black";
          language-servers = [
            {
              name = "ruff";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "rust";
          auto-format = true;
          formatter.command = "${pkgs.rustfmt}/bin/rustfmt";
          language-servers = [
            {
              name = "rust-analyzer";
              except-features = ["format"];
            }
          ];
        }
        {
          name = "sql";
          auto-format = true;
          formatter.command = "${pkgs.sqlfluff}/bin/sqlfluff format";
        }
        {
          name = "typescript";
          auto-format = true;
          language-servers = [
            {
              name = "typescript-language-server";
            }
          ];
        }
        {
          name = "wgsl";
          auto-format = true;
          language-servers = [
            {
              name = "wgsl-analyzer";
            }
          ];
        }
        {
          name = "yaml";
          auto-format = true;
          language-servers = [
            {
              name = "yaml-language-server";
            }
          ];
        }
        {
          name = "zig";
          auto-format = true;
          language-servers = [
            {
              name = "zls";
            }
          ];
        }
      ];
    };
  };
}

{
  pkgs,
  gui,
  lib,
  ...
}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraConfig = let
      mm_g = mode: ''
        [keys.${mode}.g]
        g = "goto_file_start"
        G = "goto_file_end"
        h = "goto_first_nonwhitespace"
        H = "goto_line_start"
        j = "half_page_down"
        J = "page_down"
        k = "half_page_up"
        K = "page_up"
        l = "goto_line_end"
        L = "goto_line_end_newline"
        p = "goto_file"
        d = "goto_definition"
        D = "goto_declaration"
        i = "goto_implementation"
        I = "goto_type_definition"
        f = "goto_next_function"
        F = "goto_prev_function"
        t = "goto_next_class"
        T = "goto_prev_class"
        e = "goto_next_entry"
        E = "goto_prev_entry"
        c = "goto_next_change"
        C = "goto_prev_change"
        s = "no_op"
        w = "no_op"
        n = "no_op"
        y = "no_op"
        b = "no_op"
        a = "no_op"
        m = "no_op"
      '';
      mm_p = mode: ''
        [keys.${mode}.p]
        p = "paste_after"
        P = "paste_clipboard_after"
        b = "paste_before"
        B = "paste_clipboard_before"
        r = "replace_with_yanked"
        R = "replace_selections_with_clipboard"
      '';
    in ''
      ${mm_g "normal"}
      ${mm_g "select"}
      ${mm_p "normal"}
      ${mm_p "select"}
    '';
    settings = {
      theme = lib.mkIf (!gui) "catppuccin_mocha";
      editor = {
        true-color = true;
        line-number = "relative";
        mouse = false; # change once comfortable
        cursor-shape.insert = "bar";
        shell = ["${pkgs.fish}/bin/fish" "-c"];
        bufferline = "always";
        color-modes = true;
        completion-timeout = 5; # Instant
        completion-replace = true;
        undercurl = true;
        jump-label-alphabet = "asdqwezxcrfvtgbyhnujmikolp"; # prefer keys under left hand
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

      keys = rec {
        normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
          ret = "goto_word";
          D = ["ensure_selections_forward" "extend_to_line_end"];
          C-q = ":buffer-close";

          # Redefinitions
          x = "extend_line";
          a = ["append_mode" "collapse_selection"];

          # External Integrations
          C-g = [":write-all" ":new" ":insert-output lazygit" ":buffer-close!" ":redraw" ":reload-all"];

          # Arrow Keys
          left = "goto_previous_buffer";
          right = "goto_next_buffer";
          down = "goto_next_diag";
          up = "goto_prev_diag";

          # +/-
          "+" = "increment";
          "-" = "decrement";

          space = {
            f = "file_picker_in_current_directory";
            F = "file_picker_in_current_buffer_directory";

            b = "buffer_picker";
            g = "changed_file_picker";
            j = "jumplist_picker";

            r = "symbol_picker";
            R = "workspace_symbol_picker";

            d = "diagnostics_picker";
            D = "workspace_diagnostics_picker";

            a = "code_action";
            "?" = "command_palette";
            space = "last_picker";
          };
        };

        select = {
          inherit (normal) C-q C-g x space;
          ret = "extend_to_word";
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

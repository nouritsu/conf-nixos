{
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  helix-pkg = inputs.helix.packages.${osConfig.my.system.arch}.default;
  hx = "${helix-pkg}/bin/hx";
in {
  home.shellAliases = rec {
    helix = "${hx}";
    vi = helix;
    vim = helix;
    nvim = helix;
  };

  programs.helix = {
    enable = true;
    package = helix-pkg;
    defaultEditor = true;
    extraConfig = let
      mm_g = mode:
      /*
      toml
      */
      ''
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
    in ''
      ${mm_g "normal"}
      ${mm_g "select"}
    '';
    settings = {
      editor = {
        true-color = true;
        line-number = "relative";
        cursor-shape.insert = "bar";
        shell = ["${pkgs.fish}/bin/fish" "-c"];
        bufferline = "always";
        color-modes = true;
        completion-timeout = 5; # Instant
        completion-replace = true;
        undercurl = true;
        jump-label-alphabet = "asdqwezxcrfvtgbyhnujmikolp"; # prefer keys under left hand
        cursorline = true;
        clipboard-provider = "wayland";

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
            normal = "NOR";
            insert = "INS";
            select = "SEL";
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

            e = [
              ":sh rm -f /tmp/yazi-path"
              ":insert-output yazi %{buffer_name} --chooser-file=/tmp/yazi-path"
              ":open %sh{${pkgs.uutils-coreutils-noprefix}/bin/cat /tmp/yazi-path}"
              ":redraw"
            ];

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
          inherit (normal) C-q x space;
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
          name = "fish";
          auto-format = true;
          language-servers = [
            {
              name = "fish-lsp";
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
      ];
    };
  };
}

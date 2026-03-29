{
  flake.nixosModules.whelix-lsp-rust = {
    lib,
    pkgs,
    ...
  }: let
    lldb-dap = lib.getExe' pkgs.lldb "lldb-dap";
  in {
    languages.language-server = {
      rust-analyzer = {
        command = "rust-analyzer";
        config = {
          inlayHints = {
            bindingModeHints.enable = false;
            closingBraceHints.minLines = 10;
            closureReturnTypeHints.enable = "with_block";
            discriminantHints.enable = "fieldless";
            lifetimeElisionHints.enable = "skip_trivial";
            typeHints.hideClosureInitialization = false;
          };
          files.watcher = "server";
        };
      };
    };

    languages.language = [
      {
        name = "rust";
        scope = "source.rust";
        injection-regex = "rs|rust";
        file-types = ["rs"];
        roots = ["Cargo.toml" "Cargo.lock"];
        shebangs = ["rust-script" "cargo"];
        language-servers = ["rust-analyzer"];
        persistent-diagnostic-sources = ["rustc" "clippy"];
        auto-format = true;

        comment-tokens = ["//" "///" "//!"];
        block-comment-tokens = [
          {
            start = "/*";
            end = "*/";
          }
          {
            start = "/**";
            end = "*/";
          }
          {
            start = "/*!";
            end = "*/";
          }
        ];

        auto-pairs = {
          "(" = ")";
          "{" = "}";
          "[" = "]";
          "\"" = "\"";
          "`" = "`";
        };

        indent = {
          tab-width = 4;
          unit = "    ";
        };

        debugger = {
          name = "lldb-dap";
          transport = "stdio";
          command = lldb-dap;
          templates = [
            {
              name = "binary";
              request = "launch";
              completion = [
                {
                  name = "binary";
                  completion = "filename";
                }
              ];
              args = {program = "{0}";};
            }
            {
              name = "binary (terminal)";
              request = "launch";
              completion = [
                {
                  name = "binary";
                  completion = "filename";
                }
              ];
              args = {
                program = "{0}";
                runInTerminal = true;
              };
            }
            {
              name = "attach";
              request = "attach";
              completion = ["pid"];
              args = {pid = "{0}";};
            }
            {
              name = "gdbserver attach";
              request = "attach";
              completion = [
                {
                  name = "lldb connect url";
                  default = "connect://localhost:3333";
                }
                {
                  name = "file";
                  completion = "filename";
                }
                "pid"
              ];
              args = {
                attachCommands = [
                  "platform select remote-gdb-server"
                  "platform connect {0}"
                  "file {1}"
                  "attach {2}"
                ];
              };
            }
          ];
        };
      }
    ];
  };
}

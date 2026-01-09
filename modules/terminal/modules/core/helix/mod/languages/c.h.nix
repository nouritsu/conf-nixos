{lib, pkgs, ...}: let
  clangd = lib.getExe' pkgs.clang-tools "clangd";
  lldb-dap = lib.getExe' pkgs.lldb "lldb-dap";
in {
  programs.helix.languages = {
    language-server = {
      clangd.command = clangd;
    };

    language = [
      {
        name = "c";
        scope = "source.c";
        injection-regex = "c";
        file-types = ["c"];
        language-servers = ["clangd"];
        auto-format = true;

        comment-token = "//";
        block-comment-tokens = {
          start = "/*";
          end = "*/";
        };

        indent = {
          tab-width = 2;
          unit = "  ";
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
              args = {
                console = "internalConsole";
                program = "{0}";
              };
            }
            {
              name = "attach";
              request = "attach";
              completion = ["pid"];
              args = {
                console = "internalConsole";
                pid = "{0}";
              };
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
                console = "internalConsole";
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

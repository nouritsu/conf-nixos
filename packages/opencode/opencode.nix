{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.opencode = wrappers.wrappers.opencode.wrap [
      {
        inherit pkgs;
        package = pkgs.opencode;
      }
      {
        settings = {
          theme = "catppuccin";

          # llama-swap on pc; ids match its model names
          provider.llama-swap = {
            npm = "@ai-sdk/openai-compatible";
            name = "llama-swap (local)";
            options.baseURL = "http://127.0.0.1:8080/v1";
            models = {
              "qwen3.6-35b-a3b" = {
                name = "Qwen3.6 35B-A3B (local)";
                limit = {
                  context = 65536;
                  output = 16384;
                };
              };
              "qwen3.5-9b" = {
                name = "Qwen3.5 9B (local)";
                limit = {
                  context = 32768;
                  output = 8192;
                };
              };
            };
          };

          # claude delegates edits here; read and edit only, inside the project
          agent.local = {
            description = "Local model for well-scoped edits";
            mode = "primary";
            model = "llama-swap/qwen3.6-35b-a3b";
            permission = {
              "*" = "deny";
              read = "allow";
              edit = "allow";
              glob = "allow";
              grep = "allow";
              list = "allow";
              lsp = "allow";
              todowrite = "allow";
            };
          };

          mcp = {
            context7 = {
              enabled = true;
              type = "remote";
              url = "https://mcp.context7.com/mcp";
            };

            nixos = {
              enabled = true;
              type = "local";
              command = [(lib.getExe pkgs.mcp-nixos)];
            };

            godot = {
              enabled = true;
              type = "local";
              command = [(lib.getExe self'.packages.godot-mcp)];
            };
          };

          # neither is built in; same bridge as claude-code and helix
          lsp.godot = {
            command = [(lib.getExe self'.packages.godot-lsp)];
            extensions = [".gd"];
          };
          formatter.gdscript = {
            command = [(lib.getExe pkgs.gdscript-formatter) "$FILE"];
            extensions = [".gd"];
          };
        };
      }
    ];
  };
}

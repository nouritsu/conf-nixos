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

          mcp = {
            context7 = {
              enabled = true;
              type = "remote";
              url = "https://mcp.context7.com/mcp";
            };

            nixos = {
              enabled = true;
              type = "local";
              command = ["nix" "run" "github:utensils/mcp-nixos" "--"];
            };

            godot = {
              enabled = true;
              type = "local";
              command = [(lib.getExe self'.packages.godot-mcp)];
            };
          };

          # opencode has neither built in; the server is the same bridge
          # claude-code and helix use
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

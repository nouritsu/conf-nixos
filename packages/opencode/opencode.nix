{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
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
          };
        };
      }
    ];
  };
}

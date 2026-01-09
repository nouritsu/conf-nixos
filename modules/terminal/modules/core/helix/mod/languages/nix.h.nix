{lib, pkgs, ...}: let
  nixd = lib.getExe pkgs.nixd;
  nil = lib.getExe pkgs.nil;
  alejandra = lib.getExe pkgs.alejandra;
in {
  programs.helix.languages = {
    language-server = {
      nixd.command = nixd;
      nil.command = nil;
    };

    language = [
      {
        name = "nix";
        scope = "source.nix";
        injection-regex = "nix";
        file-types = ["nix"];
        language-servers = ["nixd" "nil"];

        formatter.command = alejandra;
        auto-format = true;

        comment-token = "#";
        block-comment-tokens = {
          start = "/*";
          end = "*/";
        };

        indent = {
          tab-width = 2;
          unit = "  ";
        };
      }
    ];
  };
}

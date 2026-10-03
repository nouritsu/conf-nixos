{self, ...}: {
  flake.nixosModules.whelix-lsp-gdscript = {
    lib,
    pkgs,
    ...
  }: let
    godot-lsp = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.godot-lsp;
    gdscript-formatter = lib.getExe pkgs.gdscript-formatter;
  in {
    # helix's defaults (ncat, gdformat) aren't installed
    languages.language-server.godot.command = godot-lsp;

    languages.language = [
      {
        name = "gdscript";
        scope = "source.gdscript";
        injection-regex = "gdscript";
        file-types = ["gd"];
        roots = ["project.godot"];
        comment-tokens = ["#" "##"];
        language-servers = ["godot"];
        formatter.command = gdscript-formatter;
        indent = {
          tab-width = 4;
          unit = "\t";
        };
        auto-format = true;
      }
    ];
  };
}

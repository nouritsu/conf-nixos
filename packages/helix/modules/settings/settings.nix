{
  flake.nixosModules.whelix-settings-editor = {
    lib,
    pkgs,
    ...
  }: let
    fish = lib.getExe pkgs.fish;
  in {
    settings.editor = {
      line-number = "relative";
      cursor-shape.insert = "bar";
      shell = [
        fish
        "-c"
      ];

      indent-guides = {
        render = true;
        character = "┆";
        skip-levels = 1;
      };

      bufferline = "multiple";
      cursorline = true;
      clipboard-provider = "wayland";

      # LSP
      completion-timeout = 5; # instant
      inline-diagnostics.cursor-line = "warning";
      lsp = {
        display-messages = true;
        display-inlay-hints = true;
      };
      end-of-line-diagnostics = "hint";
    };
  };
}

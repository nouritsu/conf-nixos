{
  flake.nixosModules.whelix-settings-editor = {
    lib,
    pkgs,
    ...
  }: let
    fish = lib.getExe pkgs.fish;
    # the hx wrapper hard-sets XDG_CONFIG_HOME to its store path; children
    # (fish, yazi, lazygit) must not inherit it or they read/write there
    hxShell = pkgs.writeShellScript "hx-shell" ''
      unset XDG_CONFIG_HOME
      exec ${fish} "$@"
    '';
  in {
    settings.editor = {
      line-number = "relative";
      cursor-shape.insert = "bar";
      shell = [
        "${hxShell}"
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

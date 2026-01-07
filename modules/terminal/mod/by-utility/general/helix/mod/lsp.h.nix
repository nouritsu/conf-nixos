{
  programs.helix.settings.editor = {
    completion-timeout = 5; # instant
    inline-diagnostics.cursor-line = "warning";
    lsp = {
      display-messages = true;
      display-inlay-hints = true;
    };
    end-of-line-diagnostics = "hint";
  };
}

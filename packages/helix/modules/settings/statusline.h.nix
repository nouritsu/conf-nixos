{
  flake.nixosModules.whelix-settings-statusline = {...}: {
    settings.editor.statusline = {
      left = [
        "mode"
        "selections"
        "primary-selection-length"
        "separator"
        "position"
        "position-percentage"
      ];

      center = [
        "file-encoding"
        "file-type"
        "file-line-ending"

        "separator"
        "file-name"
        "read-only-indicator"
        "separator"

        "spacer"
        "version-control"
        "file-modification-indicator"
      ];

      right = [
        "spinner"
        "diagnostics"
        "separator"
        "workspace-diagnostics"
      ];
    };

    settings.editor.color-modes = true;
    settings.editor.statusline.mode = {
      normal = "NOR";
      insert = "INS";
      select = "SEL";
    };
  };
}

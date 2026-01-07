let
  binds_g =
    /*
    toml
    */
    ''
      a = "code_action"

      f = "goto_next_function"
      F = "goto_prev_function"

      t = "goto_next_class"
      T = "goto_prev_class"

      e = "goto_next_entry"
      E = "goto_prev_entry"

      r = "symbol_picker"
      R = "workspace_symbol_picker"

      d = "diagnostics_picker"
      D = "workspace_diagnostics_picker"
    '';
in {
  my.helix.binds_g = binds_g;

  programs.helix.settings.keys = rec {
    normal = {
      down = "goto_next_diag";
      up = "goto_prev_diag";
    };

    select = {
      inherit (normal) down up;
    };
  };
}

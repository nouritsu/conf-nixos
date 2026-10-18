{
  flake.nixosModules.whelix-keybinds-core = {...}: {
    helix'.binds_g =
      /*
      toml
      */
      ''
        g = "goto_file_start"
        G = "goto_file_end"

        h = "goto_first_nonwhitespace"
        H = "goto_line_start"

        j = "half_page_down"
        J = "page_down"

        k = "half_page_up"
        K = "page_up"

        l = "goto_line_end"
        L = "goto_line_end_newline"
      '';

    helix'.binds_space =
      /*
      toml
      */
      ''
        j = "jumplist_picker"
        "?" = "command_palette"
        space = "last_picker"
        z = ":toggle soft-wrap.enable"
      '';

    settings.keys = rec {
      normal = {
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];

        x = "select_line_below";
        X = "select_line_above";

        D = [
          "ensure_selections_forward"
          "extend_to_line_end"
        ];

        "C-s" = ":write";

        # move lines
        "A-j" = ["extend_to_line_bounds" "delete_selection" "paste_after"];
        "A-k" = ["extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before"];
      };

      select = {
        inherit (normal) x X D "C-s";
      };

      insert = {
        inherit (normal) "C-s";
      };
    };
  };
}

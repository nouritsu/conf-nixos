let
  binds_g =
    /*
    toml
    */
    ''
      c = "goto_next_change"
      C = "goto_prev_change"
    '';

  binds_space =
    /*
    toml
    */
    ''
      g = [
        ":write-all",
        ":new",
        ":insert-output lazygit",
        ":buffer-close!",
        ":redraw",
        ":reload-all"
      ]
    '';
in {
  my.helix.binds_g = binds_g;
  my.helix.binds_space = binds_space;
}

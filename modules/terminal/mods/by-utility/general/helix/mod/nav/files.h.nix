let
  binds_g =
    /*
    toml
    */
    ''
      p = "goto_file"
    '';

  binds_space =
    /*
    toml
    */
    ''
      f = "file_picker_in_current_directory"
      F = "file_picker_in_current_buffer_directory"

      e = [
        ":sh rm -f /tmp/yazi-path",
        ":insert-output yazi %{buffer_name} --chooser-file=/tmp/yazi-path",
        ":open %sh{cat /tmp/yazi-path}",
        ":redraw"
      ]

      c = "changed_file_picker"
    '';
in {
  my.helix.binds_g = binds_g;
  my.helix.binds_space = binds_space;
}

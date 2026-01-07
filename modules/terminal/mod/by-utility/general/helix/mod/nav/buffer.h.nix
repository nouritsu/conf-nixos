let
  binds_space =
    /*
    toml
    */
    ''
      b = "buffer_picker"
    '';
in {
  my.helix.binds_space = binds_space;

  programs.helix.settings.keys = rec {
    normal = {
      left = "goto_previous_buffer";
      right = "goto_next_buffer";
    };

    select = {
      inherit (normal) left right;
    };
  };
}

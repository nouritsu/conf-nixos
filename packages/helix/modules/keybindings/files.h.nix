{
  flake.nixosModules.whelix-keybinds-files = {...}: {
    helix'.binds_g =
      /*
      toml
      */
      ''
        p = "goto_file"
      '';

    helix'.binds_space =
      /*
      toml
      */
      ''
        f = "file_picker_in_current_directory"
        F = "file_picker_in_current_buffer_directory"
      '';
  };
}

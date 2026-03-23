{
  flake.nixosModules.whelix-keybinds-git = {...}: {
    helix'.binds_g =
      /*
      toml
      */
      ''
        c = "goto_next_change"
        C = "goto_prev_change"
      '';

    helix'.binds_space =
      /*
      toml
      */
      ''
        c = "changed_file_picker"
      '';
  };
}

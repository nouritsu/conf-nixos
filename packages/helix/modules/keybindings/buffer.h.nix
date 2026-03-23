{
  flake.nixosModules.whelix-keybinds-buffer = {...}: {
    helix'.binds_space =
      /*
      toml
      */
      ''
        b = "buffer_picker"
      '';

    settings.keys = rec {
      normal = {
        left = "goto_previous_buffer";
        right = "goto_next_buffer";
      };

      select = {
        inherit (normal) left right;
      };
    };
  };
}

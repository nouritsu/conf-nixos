{
  flake.nixosModules.whelix-keybinds-incdec = {...}: {
    settings.keys = rec {
      normal = {
        "+" = "increment";
        "-" = "decrement";
      };

      select = {
        inherit (normal) "+" "-";
      };
    };
  };
}

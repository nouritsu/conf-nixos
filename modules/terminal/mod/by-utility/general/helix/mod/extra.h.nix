{
  programs.helix.settings.keys = rec {
    normal = {
      "+" = "increment";
      "-" = "decrement";
    };

    select = {
      inherit (normal) "+" "-";
    };
  };
}

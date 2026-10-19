{
  programs.alejandra.enable = true;
  programs.deadnix.enable = true;
  programs.nixf-diagnose.enable = true;
  programs.statix = {
    enable = true;
    # house style: inner {...}: modules, split programs.fish.* keys
    disabled-lints = ["empty_pattern" "repeated_keys"];
  };
}

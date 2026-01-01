{
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}: let
  nerdfetch = "${pkgs.nerdfetch}/bin/nerdfetch";
  fastfetch = "${pkgs.fastfetch}/bin/fastfetch";

  onefetch = "${pkgs.onefetch}/bin/onefetch";

  cpufetch = "${pkgs.cpufetch}/bin/cpufetch";
  gpufetch =
    if is_nvidia
    then "${pkgs.gpufetch.override {cudaSupport = true;}}/bin/gpufetch"
    else "${pkgs.gpufetch}/bin/gpufetch";
  ifetch = "${pkgs.ifetch}/bin/ifetch";
  mfetch = "${pkgs.mfetch}/bin/mfetch";
  batfetch = lib.mkIf is_laptop "${inputs.batfetch.packages.${pkgs.system}.default}/bin/batfetch";

  # Meta
  is_laptop = osConfig.my.system.kind == "laptop";
  is_nvidia = osConfig.my.system.graphics == "nvidia";
in {
  home.shellAliases = {
    # Fetch
    fetch = nerdfetch;
    fetch-full = fastfetch;

    # Applications
    fetch-git = onefetch;

    # Hardware
    fetch-cpu = cpufetch;
    fetch-gpu = gpufetch;
    fetch-mem = mfetch;
    fetch-net = ifetch;
    fetch-bat = lib.mkIf is_laptop batfetch;
  };
}

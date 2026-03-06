{
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}: let
  nerdfetch = lib.getExe pkgs.nerdfetch;
  fastfetch = lib.getExe pkgs.fastfetch;

  onefetch = lib.getExe pkgs.onefetch;

  cpufetch = lib.getExe pkgs.cpufetch;
  gpufetch =
    if is_nvidia
    then lib.getExe (pkgs.gpufetch.override {cudaSupport = true;})
    else lib.getExe pkgs.gpufetch;
  ifetch = lib.getExe pkgs.ifetch;
  mfetch = lib.getExe pkgs.mfetch;
  batfetch = lib.mkIf is_laptop (lib.getExe inputs.batfetch.packages.${pkgs.system}.default);

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

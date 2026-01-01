{
  osConfig,
  lib,
  ...
}: let
  local_pkg = pkg: ../../../pkgs/${pkg}/package.nix;
in {
  programs.home-manager.enable = true;

  home = {
    username = osConfig.my.user.alias;
    homeDirectory = "/home/${osConfig.my.user.alias}";
    stateVersion = "25.11";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  nixpkgs.overlays = [
    # Local pkgs/pkg/package.nix
    (
      final: _:
        lib.genAttrs [
          "gpu-usage-waybar"
          "ifetch"
          "mfetch"
        ] (pkg: final.callPackage (local_pkg pkg) {})
    )
  ];
}

{
  den,
  inputs,
  ...
}: {
  den.default = {
    includes = [
      den.batteries.hostname
      den.batteries.define-user
      den.batteries.self'
      den.batteries.inputs'
    ];

    nixos.nixpkgs.overlays = import ../_overlays inputs;

    nixos.home-manager.useGlobalPkgs = true;
    nixos.home-manager.useUserPackages = true;

    # ================================================================ #
    # =                         DO NOT TOUCH                         = #
    # ================================================================ #
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
  };
}

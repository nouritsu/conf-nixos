{
  den,
  withSystem,
  ...
}: {
  den.default = {
    includes = [
      den.batteries.hostname
      den.batteries.define-user
      den.batteries.self'
      den.batteries.inputs'
      ({host}: {
        name = "shared-pkgs";
        nixos.nixpkgs.pkgs = withSystem host.system ({pkgs, ...}: pkgs);
      })
    ];

    # ================================================================ #
    # =                         DO NOT TOUCH                         = #
    # ================================================================ #
    nixos.system.stateVersion = "25.11";
  };
}

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

    # ================================================================ #
    # =                         DO NOT TOUCH                         = #
    # ================================================================ #
    nixos.system.stateVersion = "25.11";
  };
}

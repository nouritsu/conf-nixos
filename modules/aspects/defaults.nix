{den, ...}: {
  den.default = {
    includes = [
      den.batteries.hostname
      den.batteries.define-user

      # Hand every class module the system-selected flake outputs, so aspects
      # can say self'.packages.foo instead of threading `self` through the
      # flake-parts scope and indexing it by pkgs.stdenv.hostPlatform.system.
      den.batteries.self'
      den.batteries.inputs'
    ];

    # ================================================================ #
    # =                         DO NOT TOUCH                         = #
    # ================================================================ #
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
  };
}

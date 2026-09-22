{
  den,
  inputs,
  ...
}: {
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

    # Applied here rather than from the aspects that need an overlay, because
    # the hosts do not carry the same aspects: lenovo has niri.xwayland but not
    # kernel.cachyos-bore-lto, so hanging the list off either one silently
    # drops it on the other host.
    nixos.nixpkgs.overlays = import ../_overlays inputs;

    # Hands home-manager the host's pkgs instead of letting every user
    # evaluate its own. This is a correctness fix as much as a cost one: with
    # it off, a user's nixpkgs saw none of nixpkgs.overlays, so the cachyos
    # kernel and the xwayland-satellite fix were invisible on the HM side while
    # the host had them. den's unfree and insecure batteries already branch on
    # this flag and stop writing nixpkgs.config once it is set.
    nixos.home-manager.useGlobalPkgs = true;

    # home.packages land in /etc/profiles/per-user/$USER as part of the system
    # closure rather than an imperative ~/.nix-profile entry, so a rebuild is
    # atomic and nix profile stops carrying home-manager-path. Needs a one-time
    # `nix profile remove home-manager-path` after the first switch.
    nixos.home-manager.useUserPackages = true;

    # ================================================================ #
    # =                         DO NOT TOUCH                         = #
    # ================================================================ #
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
  };
}

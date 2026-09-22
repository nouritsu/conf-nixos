{inputs, ...}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      overlays = [(import ../_overlays/xwayland-satellite.nix)];

      # Named rather than blanket, mirroring the per-aspect den.batteries.unfree
      # discipline: spicetify wraps the unfree spotify client, and nothing else
      # under packages/ is unfree.
      config.allowUnfreePredicate = pkg:
        builtins.elem (inputs.nixpkgs.lib.getName pkg) ["spotify"];
    };
  };
}

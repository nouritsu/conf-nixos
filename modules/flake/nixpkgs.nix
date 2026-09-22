{inputs, ...}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      overlays = import ../_overlays inputs;

      # config, unlike overlays, is deliberately not shared with the host
      # instance: there den.batteries.unfree writes the predicate per aspect,
      # and a second definition here would collide with it. Named rather than
      # blanket, mirroring that discipline -- spicetify wraps the unfree
      # spotify client, and nothing else under packages/ is unfree.
      config.allowUnfreePredicate = pkg:
        builtins.elem (inputs.nixpkgs.lib.getName pkg) ["spotify" "splashtop-business"];
    };
  };
}

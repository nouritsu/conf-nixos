{
  # den.batteries.insecure names, matched without the version so bumps keep the permit
  den.default.nixos = {
    config,
    lib,
    ...
  }: {
    nixpkgs.config.allowInsecurePredicate = pkg:
      lib.elem (lib.getName pkg) config.permittedInsecurePackages.packages
      && lib.warn "permitting insecure ${lib.getName pkg} ${lib.getVersion pkg}" true;
  };
}

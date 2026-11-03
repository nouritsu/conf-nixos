{
  perSystem = {inputs', ...}: {
    packages.oniri = inputs'.oniri.packages.default.overrideAttrs (old: {
      # windows with a rule-set width keep it
      patches = (old.patches or []) ++ [./skip-app-id.patch];
      meta = old.meta // {mainProgram = "oniri";};
    });
  };
}

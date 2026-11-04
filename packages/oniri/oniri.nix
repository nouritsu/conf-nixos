{
  perSystem = {inputs', ...}: {
    packages.oniri = inputs'.oniri.packages.default.overrideAttrs (old: {
      # windows with a rule-set width keep it;
      # events from a newer niri than its pinned niri-ipc are skipped, not fatal
      patches = (old.patches or []) ++ [./skip-app-id.patch ./unknown-events.patch];
      meta = old.meta // {mainProgram = "oniri";};
    });
  };
}

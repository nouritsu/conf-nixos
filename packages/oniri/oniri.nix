{
  perSystem = {inputs', ...}: {
    packages.oniri = inputs'.oniri.packages.default.overrideAttrs (old: {
      # windows with a rule-set width keep it;
      # events from a newer niri than its pinned niri-ipc are skipped, not fatal,
      # and only window/workspace state is tracked, so unknown cast kinds can't panic it
      patches = (old.patches or []) ++ [./skip-app-id.patch ./unknown-events.patch];
      meta = old.meta // {mainProgram = "oniri";};
    });
  };
}

{
  perSystem = {inputs', ...}: {
    packages.nirimap = inputs'.nirimap.packages.default.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          # steam game windows find their steam_icon_<id>
          ./steam-icon.patch
          # behavior.overview_only: shown exactly while the overview is open
          ./overview-only.patch
        ];
    });
  };
}

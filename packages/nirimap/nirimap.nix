{
  perSystem = {inputs', ...}: {
    packages.nirimap = inputs'.nirimap.packages.default.overrideAttrs (old: {
      # steam game windows find their steam_icon_<id>
      patches = (old.patches or []) ++ [./steam-icon.patch];
    });
  };
}

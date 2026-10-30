# its check phase rebuilds the whole crate in test mode
_: prev: {
  niri = prev.niri.overrideAttrs (old: {
    doCheck = false;
    # drag to the top/bottom edge switches workspaces outside the overview too
    patches = (old.patches or []) ++ [./niri-dnd-workspace-switch.patch];
  });
}

# its check phase rebuilds the whole crate in test mode
_: prev: {
  niri = prev.niri.overrideAttrs {doCheck = false;};
}

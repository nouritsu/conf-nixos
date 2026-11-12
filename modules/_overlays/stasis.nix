# stasis 1.7.0 links sqlite3, but nixpkgs doesn't give it one
final: prev: {
  stasis = prev.stasis.overrideAttrs (old: let
    has = final.lib.elem final.sqlite old.buildInputs;
  in {
    buildInputs =
      final.lib.warnIf has "stasis gets sqlite from nixpkgs now, drop the stasis overlay"
      (old.buildInputs ++ final.lib.optional (!has) final.sqlite);
  });
}

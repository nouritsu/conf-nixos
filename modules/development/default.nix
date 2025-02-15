{supported_languages, ...}: {
  imports = [./git.nix] ++ map (s: ./languages/${s}.nix) supported_languages;
}

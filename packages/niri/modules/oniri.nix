{self, ...}: {
  flake.nixosModules.wniri-oniri = {
    config,
    lib,
    pkgs,
    ...
  }: let
    oniri = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.oniri;

    # oniri compares app-ids literally, so rules must be ^literal$
    literal = re: let
      id = lib.replaceStrings ["\\."] ["."] (lib.removePrefix "^" (lib.removeSuffix "$" re));
    in
      if builtins.match ".*[][^$*+?(){}|\\].*" id == null
      then id
      else throw "oniri: app-id rule ${re} is not ^literal$";

    # rule-set widths are kept
    sized = map literal (lib.concatMap (r: lib.catAttrs "app-id" r.matches) (
      lib.filter (r: r ? default-column-width) config.settings.window-rules
    ));
  in {
    settings = {
      layout.always-center-single-column = _: {};
      spawn-at-startup = [([oniri] ++ lib.concatMap (id: ["--skip-app-id" id]) sized)];
    };
  };
}

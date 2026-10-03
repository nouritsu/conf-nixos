# 3.2.18 can't install lovely 0.10.0 (version.dll became winmm.dll)
# drop once nixpkgs is past 3.2.18
# https://github.com/NixOS/nixpkgs/pull/556060
final: prev: {
  r2modman = prev.r2modman.overrideAttrs (finalAttrs: old: {
    version = "3.2.20";

    src = final.fetchFromGitHub {
      owner = "ebkr";
      repo = "r2modmanPlus";
      tag = "v${finalAttrs.version}";
      hash = "sha256-7zigBXnHiUYL9matqT6da5c+cXwQH8CdqpSrsrOURYE=";
    };

    missingHashes = null;
    offlineCache = null;
    pnpmDeps = final.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = final.pnpm_11;
      fetcherVersion = 4;
      hash = "sha256-xfafdQkOTLHUPeFxKn3fujZrEmK+AJ2TN85eHAvilj8=";
    };

    patches = builtins.filter (p: !final.lib.hasPrefix "yarn" (baseNameOf p)) old.patches;

    nativeBuildInputs = [
      final.copyDesktopItems
      final.dart-sass
      final.makeWrapper
      final.nodejs
      final.pnpm_11
      final.pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      substituteInPlace node_modules/.pnpm/sass-embedded@*/node_modules/sass-embedded/dist/lib/src/compiler-path.js \
        --replace-fail 'compilerCommand = (() => {' 'compilerCommand = (() => { return ["${final.lib.getExe final.dart-sass}"];'

      pnpm quasar build --mode electron --skip-pkg
      pnpm prune --prod

      runHook postBuild
    '';
  });
}

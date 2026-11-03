{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.nirinit = pkgs.rustPlatform.buildRustPackage {
      pname = "nirinit";
      version = "${(lib.importTOML "${inputs.nirinit}/Cargo.toml").package.version}-${inputs.nirinit.shortRev}";
      src = inputs.nirinit;
      cargoLock.lockFile = "${inputs.nirinit}/Cargo.lock";
      meta.mainProgram = "nirinit";
    };
  };
}

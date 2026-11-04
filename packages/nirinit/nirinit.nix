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

      # columns, stacks, floating and focus come back as they were, once per niri session;
      # launch commands get the old window's id in NIRINIT_WINDOW_ID
      patches = [./restore-layout.patch];

      meta.mainProgram = "nirinit";
    };
  };
}

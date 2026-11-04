{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    # needs --checks; the isup aspect bakes in the host's list
    packages.isup = pkgs.buildGoModule {
      pname = "isup";
      version = "0.1.0";
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [./go.mod ./go.sum ./main.go];
      };
      vendorHash = "sha256-jdXVrBrrFmM4Of4wCFzsa2J4naHOSc6VOg8fSYU7AFM=";
      meta.mainProgram = "isup";
    };
  };
}

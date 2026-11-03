{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    # puts a fullscreened window back in its column, niri-wm/niri#426
    packages.nfsm = pkgs.stdenvNoCC.mkDerivation {
      pname = "nfsm";
      version = "0.0.1-${inputs.nfsm.shortRev}";
      src = inputs.nfsm;

      patches = [./floating.patch];

      nativeBuildInputs = [pkgs.makeWrapper];
      buildInputs = [pkgs.python3];

      installPhase = ''
        install -Dm755 src/nfsm.py $out/bin/nfsm
        wrapProgram $out/bin/nfsm --prefix PATH : ${lib.makeBinPath [pkgs.niri pkgs.coreutils]}
      '';

      meta.mainProgram = "nfsm";
    };

    # plain fullscreen-window when the daemon is down
    packages.nfsm-cli = pkgs.callPackage "${inputs.nfsm}/src/cli.nix" {};
  };
}

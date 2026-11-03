{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.niri-ror = pkgs.stdenvNoCC.mkDerivation {
      pname = "niri-ror";
      version = "0-${inputs.niri-ror.shortRev}";
      src = inputs.niri-ror;

      nativeBuildInputs = [pkgs.makeWrapper];
      buildInputs = [pkgs.bash];

      # the Makefile only lints
      dontBuild = true;

      # finds its jq modules next to itself
      installPhase = ''
        mkdir -p $out/share/niri-ror
        cp -r ror.sh ws.jq lib $out/share/niri-ror/
        makeWrapper $out/share/niri-ror/ror.sh $out/bin/niri-ror \
          --prefix PATH : ${lib.makeBinPath [pkgs.jq pkgs.niri pkgs.libnotify pkgs.coreutils]}
      '';

      meta.mainProgram = "niri-ror";
    };
  };
}

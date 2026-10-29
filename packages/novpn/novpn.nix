{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # stays the parent of the command, so split tunneling matches it and everything below
    novpn =
      pkgs.runCommand "novpn" {
        nativeBuildInputs = [pkgs.makeBinaryWrapper];
        meta.mainProgram = "novpn";

        passthru.wrap = pkg: let
          exe = lib.getExe pkg;
          bin = baseNameOf exe;
        in
          pkgs.symlinkJoin {
            name = "${bin}-novpn";
            paths = [pkg];
            nativeBuildInputs = [pkgs.makeBinaryWrapper];
            postBuild = ''
              rm $out/bin/${bin}
              makeWrapper ${lib.getExe novpn} $out/bin/${bin} --add-flag ${exe}
            '';
            meta.mainProgram = bin;
          };
      } ''
        # own copy, the exe path is what gets matched
        install -Dm755 ${pkgs.tini}/bin/tini $out/libexec/novpn
        makeWrapper $out/libexec/novpn $out/bin/novpn --add-flags "-s --"
      '';
  in {
    packages.novpn = novpn;
  };
}

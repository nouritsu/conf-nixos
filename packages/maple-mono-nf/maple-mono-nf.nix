{
  perSystem = {pkgs, ...}: {
    # wide nerd icons centred over their cell and the space after it
    packages.maple-mono-nf =
      pkgs.runCommand "maple-mono-nf-${pkgs.maple-mono.NF.version}" {
        nativeBuildInputs = [(pkgs.python3.withPackages (p: [p.fonttools]))];
      } ''
        cp -r --no-preserve=mode ${pkgs.maple-mono.NF} $out
        python3 ${./centre-icons.py} $out/share/fonts/truetype/*.ttf
      '';
  };
}

{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.niri-pip = pkgs.rustPlatform.buildRustPackage {
      pname = "niri-pip";
      version = "${(lib.importTOML "${inputs.niri-pip}/Cargo.toml").workspace.package.version}-${inputs.niri-pip.shortRev}";
      src = inputs.niri-pip;
      cargoLock.lockFile = "${inputs.niri-pip}/Cargo.lock";

      nativeBuildInputs = [pkgs.python3 pkgs.makeWrapper];

      # mocha + mauve settings page; the css is compiled in
      postPatch = ''
        python3 -I ${./catppuccin.py} crates/niripip-ui/assets/app.css
      '';

      postInstall = ''
        mkdir -p $out/share/applications
        substitute packaging/desktop/niri-pip.desktop.in $out/share/applications/niri-pip.desktop \
          --replace-fail @NIRIPIP@ $out/bin/niripip
        # niripip media
        wrapProgram $out/bin/niripip --prefix PATH : ${lib.makeBinPath [pkgs.playerctl]}
      '';

      meta.mainProgram = "niripip";
    };
  };
}

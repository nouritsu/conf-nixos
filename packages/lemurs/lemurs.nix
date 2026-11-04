{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    # main: 0.4.0 opens the session in lemurs itself, so logind gives it no seat and a second login hangs
    packages.lemurs = pkgs.rustPlatform.buildRustPackage {
      pname = "lemurs";
      version =
        lib.warnIf (lib.versionOlder "0.4.0" pkgs.lemurs.version)
        "nixpkgs has lemurs ${pkgs.lemurs.version}; drop the main pin if it has the seat fix"
        "0.4.0-${inputs.lemurs.shortRev}";

      src = inputs.lemurs;
      cargoLock.lockFile = "${inputs.lemurs}/Cargo.lock";

      # centered like tuigreet, and redrawn when fbcon takes the console over after the first frame;
      # an empty password asks for a touch; autologin_if_exists logs in once without showing the form
      patches = [./centered.patch ./touch-cue.patch ./autologin.patch];

      buildInputs = [pkgs.linux-pam];

      postInstall = ''
        install -Dm0755 extra/xsetup.sh "$out/etc/xsetup.sh"
      '';

      inherit (pkgs.lemurs) meta;
    };
  };
}

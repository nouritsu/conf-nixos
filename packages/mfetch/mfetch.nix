{
  perSystem = {pkgs, ...}: let
    cargoLockFile = ./Cargo.lock;
  in {
    packages.mfetch = pkgs.rustPlatform.buildRustPackage rec {
      pname = "mfetch";
      version = "0.3.2";

      src = pkgs.fetchFromGitHub {
        owner = "xdearboy";
        repo = "mfetch";
        rev = "v${version}";
        hash = "sha256-hTLb71rhFiYICn3jI9hLPHd3tCRAnc3r1TtmRYbw88Y=";
      };

      cargoLock = {
        lockFile = cargoLockFile;
        allowBuiltinFetchGit = true;
      };

      postPatch = ''
        cp ${cargoLockFile} Cargo.lock
      '';

      meta = {
        description = "memory-focused system info tool written in Rust for linux.";
        homepage = "https://github.com/xdearboy/mfetch";
        license = pkgs.lib.licenses.mit;
        mainProgram = "mfetch";
        platforms = pkgs.lib.platforms.linux;
      };
    };
  };
}

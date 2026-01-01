{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "mfetch";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "xdearboy";
    repo = "mfetch";
    rev = "v${version}";
    hash = "sha256-hTLb71rhFiYICn3jI9hLPHd3tCRAnc3r1TtmRYbw88Y=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "📦 memory-focused system info tool written in Rust for linux.";
    homepage = "https://github.com/xdearboy/mfetch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [nouritsu];
    mainProgram = "mfetch";
    platforms = lib.platforms.linux;
  };
}

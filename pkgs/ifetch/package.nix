{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "ifetch";
  version = "0-unstable-2024-12-29";

  src = fetchFromGitHub {
    owner = "deivshon";
    repo = "ifetch";
    rev = "09f80fb9574c783169b750de3cc18045fe846d2a";
    hash = "sha256-AqpD2m51WWf3YH2Lf2tdCLLIeed8TdGKg3tFIUm26o4=";
  };

  makeFlags = [
    "DEST_DIR=$(out)"
    "INSTALL_DIR=/bin"
    "ETC_CONFIG_DIR=/etc/ifetch"
  ];

  meta = {
    description = "Fetch tool for Linux systems to display network interface information";
    homepage = "https://github.com/deivshon/ifetch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [nouritsu];
    platforms = lib.platforms.linux;
    mainProgram = "ifetch";
  };
}

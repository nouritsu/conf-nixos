{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    <nixos-wsl/modules>
    ./apps/default.nix
    (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  ];

  # WSL
  wsl.enable = true;
  wsl.defaultUser = "nouritsu";

  # Services
  services.vscode-server.enable = true;

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "24.05";
}

{
  pkgs,
  user,
  hostname,
  ...
}: {
  wsl = {
    enable = true;
    defaultUser = user.alias;
    interop.includePath = false;
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  networking.hostName = hostname;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "24.05";
}

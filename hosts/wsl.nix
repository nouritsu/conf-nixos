{
  pkgs,
  user,
  ...
}: {
  wsl = {
    enable = true;
    defaultUser = user.alias;
    wslConf.interop = {
      enabled = false;
      appendWindowsPath = false;
    };
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ================================================================ #
  # =                         DO NOT TOUCH                         = #
  # ================================================================ #
  system.stateVersion = "24.05";
}

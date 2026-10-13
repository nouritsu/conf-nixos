{self, ...}: {
  flake.nixosModules.wniri-startup = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
    afterTray = cmd: [(pkgs.lib.getExe self.packages.${system}.wait-for-tray)] ++ cmd;
  in {
    settings.spawn-at-startup = [
      (afterTray ["steam" "-silent"])
      (afterTray ["vesktop" "--start-minimized"])
      ["gsr-ui" "launch-daemon"]
    ];
  };
}

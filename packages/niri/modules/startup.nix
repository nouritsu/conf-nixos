{
  flake.nixosModules.wniri-startup = {pkgs, ...}: let
    delay = toString 5;
    delayed = cmd: ["${pkgs.runtimeShell}" "-c" "sleep ${delay}; exec ${pkgs.lib.escapeShellArgs cmd}"];
  in {
    settings.spawn-at-startup = [
      (delayed ["steam" "-silent"])
      (delayed ["vesktop" "--start-minimized"])
    ];
  };
}

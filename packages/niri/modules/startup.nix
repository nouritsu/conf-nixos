{
  flake.nixosModules.wniri-startup = {pkgs, ...}: let
    delay = toString 5;
    delayed = cmd: ["${pkgs.runtimeShell}" "-c" "sleep ${delay}; exec ${pkgs.lib.escapeShellArgs cmd}"];
  in {
    settings.spawn-at-startup = [
      # system
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ["gnome-keyring-daemon" "--start" "--components=secrets,pkcs11,ssh"]

      # user/core
      ["dms" "run"]
      "kdeconnectd"

      # user/extra
      (delayed ["steam" "-silent"])
      (delayed ["vesktop" "--start-minimized"])
    ];
  };
}

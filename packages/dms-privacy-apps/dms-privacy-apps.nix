{
  perSystem = {pkgs, ...}: let
    # a stream's pid -> its app's main process (oldest ancestor on the same
    # binary, so a browser's audio helper resolves to the browser) and binary
    owner = pkgs.writeShellApplication {
      name = "dms-privacy-apps-owner";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        exe=$(readlink "/proc/$1/exe")
        top=$1
        while :; do
          ppid=0
          while read -r key value; do
            if [ "$key" = PPid: ]; then
              ppid=$value
              break
            fi
          done < "/proc/$top/status"
          if [ "$ppid" -le 1 ] || [ "$(readlink "/proc/$ppid/exe")" != "$exe" ]; then
            break
          fi
          top=$ppid
        done
        echo "$top ''${exe##*/}"
      '';
    };
  in {
    # dms widget: the privacy indicator, plus a popout of the apps behind it
    packages.dms-privacy-apps = pkgs.runCommand "dms-privacy-apps" {} ''
      mkdir $out
      cp ${./plugin.json} $out/plugin.json
      cp ${./PrivacyAppsWidget.qml} $out/PrivacyAppsWidget.qml
      cp ${./PrivacyAppsSettings.qml} $out/PrivacyAppsSettings.qml
      substitute ${./PrivacyAppsDaemon.qml} $out/PrivacyAppsDaemon.qml \
        --replace-fail @owner@ ${pkgs.lib.getExe owner}
    '';
  };
}

{
  perSystem = {pkgs, ...}: {
    # dux widget: a gamepad while game mode is on
    packages.dux-game-mode = pkgs.runCommand "dux-game-mode" {} ''
      mkdir $out
      cp ${./plugin.json} $out/plugin.json
      cp ${./GameModeWidget.qml} $out/GameModeWidget.qml
    '';
  };
}

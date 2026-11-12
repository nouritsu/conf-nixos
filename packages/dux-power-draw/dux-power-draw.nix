{
  perSystem = {pkgs, ...}: let
    # one json line a second: rapl counters, the ec's cpu rail, tctl, clocks and cpu time
    sampler = pkgs.writeShellApplication {
      name = "dux-power-draw-sampler";
      runtimeInputs = [pkgs.coreutils];
      text = builtins.readFile ./sampler.sh;
    };
  in {
    # dux widget: cpu and gpu power draw, their history and energy use
    packages.dux-power-draw = pkgs.runCommand "dux-power-draw" {} ''
      mkdir $out
      cp ${./plugin.json} $out/plugin.json
      cp ${./PowerDrawWidget.qml} $out/PowerDrawWidget.qml
      substitute ${./PowerDrawDaemon.qml} $out/PowerDrawDaemon.qml \
        --replace-fail @sampler@ ${pkgs.lib.getExe sampler}
    '';
  };
}

{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.replay-fish = pkgs.fishPlugins.buildFishPlugin {
      pname = "replay";
      version = "1.2.1-${inputs.replay-fish.shortRev}";
      src = inputs.replay-fish;
    };
  };
}

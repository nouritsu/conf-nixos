{
  perSystem = {pkgs, ...}: {
    packages.replay-fish = pkgs.fishPlugins.buildFishPlugin {
      pname = "replay";
      version = "1.2.1-unstable-2024-07-01";
      src = pkgs.fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "replay.fish";
        rev = "d2ecacd3fe7126e822ce8918389f3ad93b14c86c";
        hash = "sha256-TzQ97h9tBRUg+A7DSKeTBWLQuThicbu19DHMwkmUXdg=";
      };
      passthru.nup = ["--version=branch"];
    };
  };
}

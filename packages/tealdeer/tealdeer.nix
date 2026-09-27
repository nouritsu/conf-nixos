{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
    # tldr refreshes its own cache on use, which is what home-manager's
    # tldr-update timer used to do in the background
    packages.tealdeer = wrappers.wrappers.tealdeer.wrap [
      {
        inherit pkgs;
        package = pkgs.tealdeer;
      }
      {
        settings.updates = {
          auto_update = true;
          auto_update_interval_hours = 24;
        };
      }
    ];
  };
}

{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
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

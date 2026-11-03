{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.atuin = wrappers.wrappers.atuin.wrap [
      {
        inherit pkgs;
        package = pkgs.atuin;
      }
      {
        settings = {
          sync_address = "https://atuin.nouritsu.com";
          # nix updates it
          update_check = false;

          filter_mode = "host";
          enter_accept = true;
          ui.columns = ["duration" "time" "host" "command"];

          theme.name = "catppuccin-mocha-mauve";

          # also leaves ? unbound in the shell
          ai.enabled = false;
        };

        # read from beside config.toml while ~/.atuin/themes doesn't exist
        constructFiles.theme = {
          relPath = "atuin-config/themes/catppuccin-mocha-mauve.toml";
          builder = ''cp ${inputs'.catppuccin.packages.atuin}/mocha/catppuccin-mocha-mauve.toml "$2"'';
        };
      }
    ];
  };
}

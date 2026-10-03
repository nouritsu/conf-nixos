{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.lazygit = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.lazygit;
      }
      {
        env.LG_CONFIG_FILE = "${inputs'.catppuccin.packages.lazygit}/mocha/mauve.yml";
      }
    ];
  };
}

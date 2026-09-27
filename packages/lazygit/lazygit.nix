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
        # env rather than envDefault: a session started before the switch still
        # carries home-manager's LG_CONFIG_FILE until the next login. Only the
        # config is redirected; state.yml stays in ~/.config/lazygit.
        env.LG_CONFIG_FILE = "${inputs'.catppuccin.packages.lazygit}/mocha/mauve.yml";
      }
    ];
  };
}

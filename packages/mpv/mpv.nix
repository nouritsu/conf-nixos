{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.mpv = wrappers.wrappers.mpv.wrap [
      {
        inherit pkgs;
        package = pkgs.mpv;
      }
      {
        "mpv.conf".content = ''
          include="${inputs'.catppuccin.packages.mpv}/mocha/mauve.conf"
        '';
      }
    ];
  };
}

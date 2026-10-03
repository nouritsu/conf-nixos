{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.zathura = wrappers.wrappers.zathura.wrap [
      {inherit pkgs;}
      {
        extraSettings = ''
          include ${inputs'.catppuccin.packages.zathura}/catppuccin-mocha
        '';
      }
    ];
  };
}

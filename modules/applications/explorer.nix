{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.app-explorer = {...}: {
    my.hmModules = ["app-explorer"];

    imports = [
      self.nixosModules.app-wezterm
      self.nixosModules.app-yazi
    ];
  };

  flake.homeModules.app-explorer = {
    lib,
    pkgs,
    osConfig,
    ...
  }: let
    wezterm-pkg = inputs.wezterm.packages.${osConfig.my.system.arch}.default;
    yazi-pkg = inputs.yazi.packages.${osConfig.my.system.arch}.default;

    yazi = lib.getExe yazi-pkg;
    wezterm = rec {
      bin = lib.getExe' wezterm-pkg "wezterm-gui";
      cwd = ""; # TODO
    };
    nautilus = rec {
      bin = lib.getExe pkgs.nautilus;
      cwd = ""; # TODO
    };
  in {
    home.packages = [
      pkgs.nautilus
    ];
  };
}

{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    scheme = pkgs.catppuccin-kde.override {
      flavour = ["mocha"];
      accents = ["mauve"];
    };

    enforce = pkgs.writeShellApplication {
      name = "kdenlive-theme";
      runtimeInputs = [pkgs.crudini];
      text = ''
        # first run writes the file itself
        config=''${XDG_CONFIG_HOME:-$HOME/.config}/kdenliverc
        if [ -f "$config" ]; then
          crudini --ini-options=nospace --set "$config" UiSettings ColorScheme CatppuccinMochaMauve
        fi
      '';
    };
  in {
    packages.kdenlive = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.kdePackages.kdenlive;
      }
      {
        runShell = [
          ''export XDG_DATA_DIRS=${scheme}/share:''${XDG_DATA_DIRS:-/run/current-system/sw/share}''
          "${lib.getExe enforce} || true"
        ];
      }
    ];
  };
}

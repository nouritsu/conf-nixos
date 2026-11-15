{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    pins = {
      baseTheme = "catppuccinMocha";
      mainColor = "CatppuccinMochaMauve";
      secColor = "CatppuccinMochaMauve";
      useSponsorBlock = true;
      # the wrapped mpv from PATH, with its own sponsorblock and uosc
      externalPlayer = "mpv";
    };

    # nedb lines; the last line per _id wins and freetube compacts the file on load
    lines = pkgs.writeText "freetube-pins.db" (lib.concatMapAttrsStringSep "\n" (id: value:
        builtins.toJSON {
          _id = id;
          inherit value;
        })
      pins
      + "\n");

    enforce = pkgs.writeShellApplication {
      name = "freetube-pin-settings";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        dir=''${XDG_CONFIG_HOME:-$HOME/.config}/FreeTube
        mkdir -p "$dir"
        cat ${lines} >>"$dir/settings.db"
      '';
    };
  in {
    packages.freetube = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.freetube;
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}

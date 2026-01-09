{
  lib,
  config,
  ...
}: let
  waybar_lib = rec {
    # Convert a name, color to a GTK CSS define-color rule
    mk_define = name: color: "@define-color ${name} ${color};";
    # Convert a list ["name1: color1", "name2: color2"] into GTK CSS define-color rules
    mk_batch_defines = list:
      lib.concatStringsSep "\n" (map (
          str: let
            parts = lib.splitString ":" str;
          in
            mk_define (lib.trim (lib.head parts)) (lib.trim (lib.last parts))
        )
        list);

    # Theme colour palette
    palette =
      lib.mapAttrs (_: color: color.hex)
      (lib.importJSON "${config.catppuccin.sources.palette}/palette.json").mocha.colors;

    div = let
      reverse_str = s:
        lib.pipe s [
          lib.stringToCharacters
          lib.reverseList
          lib.concatStrings
        ];
    in
      # direction[i: inverted e: extended]
      lib.mapAttrs (_: s: {
        format = s;
        tooltip = false;
      }) rec {
        l = "";
        li = "";
        le = "${l}${li}";
        lei = "${reverse_str le}";

        r = "";
        ri = "";
        re = "${r}${ri}";
        rei = "${reverse_str re}";
      };
  };
in {
  options.my.waybar.styles = {
    define_parts = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "css @define-color declarations";
    };
    parts = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "css rules for individual modules";
    };
  };

  config._module.args.waybar_lib = waybar_lib;
}

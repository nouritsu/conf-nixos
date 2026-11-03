{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: let
    src = inputs.liixini-shaders;
    dirs = lib.filter (dir: builtins.pathExists "${src}/${dir}/close.glsl") (
      lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir src))
    );

    # the shader's own curve or spring; windowFx's sliders keep the length
    timing = dir: side: let
      own = "${src}/${dir}/${side}-config";
      file =
        if builtins.pathExists own
        then own
        else "${src}/${dir}/config";
    in
      lib.concatStringsSep " " (lib.filter (l: l != "" && !lib.hasPrefix "duration-ms" l) (lib.splitString "\n" (builtins.readFile file)));

    title = dir: lib.concatMapStringsSep " " (w: lib.toUpper (lib.substring 0 1 w) + lib.substring 1 (-1) w) (lib.splitString "-" dir);

    kinds = pkgs.writeText "Liixini.js" ''
      .pragma library

      var list = ${builtins.toJSON (map (dir: {
          key = "liixini-${dir}";
          label = "${title dir} (liixini)";
          inherit dir;
          close = timing dir "close";
          open = timing dir "open";
        })
        dirs)};

      function byKey(key) {
          for (var i = 0; i < list.length; i++) {
              if (list[i].key === key)
                  return list[i];
          }
          return null;
      }
    '';
  in {
    # windowFx with liixini/shaders as extra close/open kinds
    packages.dux-window-fx = pkgs.applyPatches {
      name = "dux-plugin-windowFx";
      src = inputs'.dux-plugin-registry.packages.windowFx;
      patches = [./liixini.patch];
      postPatch =
        ''
          cp ${kinds} Liixini.js
          mkdir -p shaders/liixini
        ''
        + lib.concatMapStrings (dir: ''
          cp -r ${src}/${dir} shaders/liixini/${dir}
        '')
        dirs;
    };
  };
}

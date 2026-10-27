{inputs, ...}: let
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  # on every host, so any aspect can add entries
  den.default.nixos = {lib, ...}: let
    # group > app > nested group
    entry = depth:
      lib.types.submodule {
        options =
          {
            desc = lib.mkOption {type = lib.types.str;};
            # nerd font codepoint in hex
            icon = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
            cmd = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            # case-insensitive regex; a matching window is focused instead
            app-id = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
          }
          // lib.optionalAttrs (depth > 1) {
            submenu = lib.mkOption {
              type = lib.types.attrsOf (entry (depth - 1));
              default = {};
            };
          };
      };
  in {
    options.which-key'.menu = lib.mkOption {
      type = lib.types.attrsOf (entry 3);
      default = {};
    };
  };

  den.aspects.which-key.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: let
    # through json escapes, so no glyphs live in the source
    glyph = hex: let
      cp = lib.fromHexString hex;
      u = n: "\\u${lib.toHexString n}";
      escaped =
        if cp < 65536
        then u cp
        else u (55296 + (cp - 65536) / 1024) + u (56320 + lib.mod (cp - 65536) 1024);
    in
      builtins.fromJSON ''"${escaped}"'';

    span = colour: text: ''<span foreground="#${colour}">${text}</span>'';
    label = e: lib.optionalString (e.icon != "") "${glyph e.icon} " + lib.escapeXML e.desc;

    focus = pkgs.writeShellApplication {
      name = "niri-focus-or-run";
      runtimeInputs = [
        config.programs.niri.package
        pkgs.jq
      ];
      text = ''
        app=$1
        shift
        id=$(niri msg --json windows | jq --arg app "$app" 'first(.[] | select(.app_id // "" | test($app; "i")) | .id) // empty') || id=
        if [ -n "$id" ]; then
          exec niri msg action focus-window --id "$id"
        fi
        exec "$@"
      '';
    };

    run = e:
      if e.app-id != null
      then "${lib.getExe focus} ${lib.escapeShellArg e.app-id} ${e.cmd}"
      else e.cmd;

    # ordered by key; empty groups dropped
    toMenu = entries:
      lib.sort (a: b: lib.toLower a.key < lib.toLower b.key) (lib.concatLists (lib.mapAttrsToList (
          key: e:
            if e.cmd != null
            then [
              {
                inherit key;
                desc = label e;
                cmd = run e;
              }
            ]
            else let
              submenu = toMenu (e.submenu or {});
            in
              lib.optional (submenu != []) {
                inherit key submenu;
                desc = span palette.base0E (label e);
              }
        )
        entries));

    which-key = inputs.wrappers.wrappers.wlr-which-key.wrap [
      {inherit pkgs;}
      {
        settings = {
          font = "Maple Mono NF 13";
          background = "#${palette.base00}";
          color = "#${palette.base05}";
          border = "#${palette.base0E}";
          separator = span palette.base04 " ${glyph "279c"} ";
          border_width = 2;
          corner_r = 12;
          padding = 16;

          anchor = "bottom-right";
          # struts + gaps, so it lines up with windows
          margin_right = 9;
          margin_bottom = 9;

          menu = toMenu config.which-key'.menu;
        };
      }
    ];

    # one menu at a time; -o keeps the lock out of the apps it launches
    single = pkgs.writeShellApplication {
      name = "wlr-which-key";
      runtimeInputs = [pkgs.util-linux];
      text = ''
        exec flock -n -o "''${XDG_RUNTIME_DIR:-/tmp}/wlr-which-key.lock" ${lib.getExe which-key} "$@"
      '';
    };
  in {
    environment.systemPackages = [single];

    which-key'.menu = {
      c = {
        desc = "Chat";
        icon = "f028c";
      };
      m = {
        desc = "Media";
        icon = "f040c";
      };
      g = {
        desc = "Games";
        icon = "f0297";
      };
      p = {
        desc = "Proton";
        icon = "f099d";
      };
      o = {
        desc = "Office";
        icon = "f00d6";
      };
      h = {
        desc = "Homelab";
        icon = "f048b";
      };
      s = {
        desc = "System";
        icon = "f0493";
      };
      t = {
        desc = "Tools";
        icon = "f09ac";
      };
    };
  };
}

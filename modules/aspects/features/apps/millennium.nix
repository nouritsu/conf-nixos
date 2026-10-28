{
  den.aspects.extra.provides.millennium.nixos = {
    pkgs,
    lib,
    self',
    ...
  }: let
    jq = lib.getExe pkgs.jq;

    # folder = plugin.json name, file = <id>.star
    pluginSrcs = {
      "me.tysmith.steam-native-notifications.star" = self'.packages.millennium-steam-native-notifications;
      achievement-groups = self'.packages.millennium-achievement-groups;
      extendium = self'.packages.millennium-extendium;
      global_launch_options = self'.packages.millennium-global-launch-options;
      hltb-for-millennium = self'.packages.millennium-hltb;
      protondb-library-badges = self'.packages.millennium-protondb-library-badges;
      "size-on-disk.star" = self'.packages.millennium-size-on-disk;
    };
    plugins = pkgs.linkFarm "millennium-plugins" pluginSrcs;

    # folder = theme id in the config
    themes = pkgs.linkFarm "millennium-themes" {
      Adwaita-for-Steam = self'.packages.adwaita-for-steam;
    };

    # merged into Millennium's config on every start, GUI changes revert
    settings = {
      general = {
        accentColor = "DEFAULT_ACCENT_COLOR";
        checkForMillenniumUpdates = true;
        checkForPluginAndThemeUpdates = true;
        injectCSS = true;
        injectJavascript = true;
        millenniumUpdateChannel = "stable";
        onMillenniumUpdate = 1;
        shouldShowThemePluginUpdateNotifications = true;
      };
      notifications = {
        showNotifications = true;
        showPluginNotifications = true;
        showUpdateNotifications = true;
      };
      plugins = {
        # everything packaged above
        enabledPlugins = map (lib.removeSuffix ".star") (builtins.attrNames pluginSrcs);
        # desktop notifications only, DMS draws them over fullscreen games
        "me.tysmith.steam-native-notifications".config = {
          notifyOutsideGame = true;
          notifyInGame = true;
          showSteamOutsideGame = false;
          showSteamInGame = false;
        };
      };
      themes = {
        activeTheme = "Adwaita-for-Steam";
        allowedScripts = true;
        allowedStyles = true;
        conditions.Adwaita-for-Steam = {
          "Color theme" = "Catppuccin Mocha";
          "Color scheme" = "Dark";
          # mauve in Catppuccin Mocha
          "Accent color" = "Purple";
          "Font" = "System";
          "Hide games list" = "no";
          "Login QR code" = "Show";
          "Pointer cursor" = "no";
          "Rounded corners" = "yes";
          "Show URL" = "no";
          "Square icons in game details" = "yes";
          "What's New shelf" = "yes";
          "Window controls layout" = "Adwaita";
          "Window controls theme" = "Adwaita (GNOME)";
        };
      };
    };
  in {
    # runs inside the FHS env before every Steam start
    programs.steam.package = pkgs.millennium-steam.override {
      extraProfile = ''
        (
          sync() {
            for link in "$1"/*; do
              src=$(readlink -f "$link")
              dst=$2/$(basename "$link")
              # .star plugins are never unpacked or written to
              if [ -f "$src" ]; then
                # drop our copy from before it became a .star
                [ -f "''${dst%.star}/.nix-source" ] && rm -rf "''${dst%.star}"
                ln -sf "$src" "$dst"
                continue
              fi
              [ "$(cat "$dst/.nix-source" 2>/dev/null)" = "$src" ] && continue

              # copied, not linked: plugins keep their cache and settings next to their code
              mkdir -p "$dst"
              cp -rT --no-preserve=mode,ownership "$src" "$dst"
              # Millennium's updater keys on this; versions come from here
              rm -f "$dst/metadata.json"
              printf '%s' "$src" > "$dst/.nix-source"
            done
          }

          sync ${plugins} "''${XDG_DATA_HOME:-$HOME/.local/share}/millennium/plugins"
          # themes live under this link, which Steam makes on its first start
          [ -d "$HOME/.steam/steam" ] && sync ${themes} "$HOME/.steam/steam/millennium/themes"

          # only once Millennium has written its config
          cfg=''${XDG_CONFIG_HOME:-$HOME/.config}/millennium/config.json
          want=${lib.escapeShellArg (builtins.toJSON settings)}
          if [ -f "$cfg" ] && ! ${jq} -e --argjson want "$want" '. * $want == .' "$cfg" >/dev/null; then
            new=$(${jq} --argjson want "$want" '. * $want' "$cfg") && printf '%s\n' "$new" > "$cfg"
          fi
        ) || true

        # stock Steam without a rebuild; the bootstrap is relinked on the next normal start
        if [ -n "''${STEAM_NO_MILLENNIUM-}" ]; then
          rm -f "$HOME/.local/share/Steam/ubuntu12_32/libXtst.so.6" "$HOME/.local/share/Steam/ubuntu12_64/libXtst.so.6"
        fi
      '';
    };

    # steam-native-notifications shells out to these
    programs.steam.extraPackages = [pkgs.curl pkgs.libnotify];

    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "steam-no-millennium";
        desktopName = "Steam (no Millennium)";
        exec = "env STEAM_NO_MILLENNIUM=1 steam %U";
        icon = "steam";
        categories = ["Game"];
      })
    ];

    which-key'.menu.g.submenu.n = {
      desc = "Steam (no Millennium)";
      icon = "f04d3";
      cmd = "env STEAM_NO_MILLENNIUM=1 steam";
    };
  };
}

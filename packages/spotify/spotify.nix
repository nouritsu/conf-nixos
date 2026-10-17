{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: let
    spicePkgs = inputs'.spicetify-nix.legacyPackages;

    # extension settings, written to localStorage before the extensions load
    storage = {
      "catppuccin-accentColor" = "mauve";
      "sidebar-customizer-prefs" = builtins.toJSON {
        friendActivity = false;
        whatsNew = false;
        queue = true;
        connect = true;
        nowPlaying = true;
        albumArtHandler = true;
      };
      # merged over the defaults; f stays keyboardShortcut's hint key
      "full-screen-config" = builtins.toJSON {
        fsHideOriginal = true;
        buttonActivation = "def";
        keyActivation = "tv";
      };
      # no changelog popups
      "whats-new_full-screen-version" = "999.0.0";
    };

    # dropped on launch so these fall back to the extension defaults
    resets = [
      "^lyrics-plus:(visual|provider):"
      "^lyrics-plus:services-order$"
      "^new-releases:(?!dismissed$)"
      "^CoverAmbienceBorderOpacity$"
    ];

    pinSettings = pkgs.writeTextDir "pinSettings.js" ''
      (() => {
        const reset = new RegExp(${builtins.toJSON (lib.concatStringsSep "|" resets)});
        for (const key of Object.keys(localStorage)) {
          if (reset.test(key)) localStorage.removeItem(key);
        }
        for (const [key, value] of Object.entries(${builtins.toJSON storage})) {
          localStorage.setItem(key, value);
        }
      })();
    '';

    # null drops the key so spotify uses its default
    prefs = {
      global = {
        "app.autostart-mode" = "off";
      };
      user = {
        "app.player.autoplay" = null;
        "audio.allow_downgrade" = false;
        "audio.crossfade_v2" = null;
        "audio.crossfade.time_v2" = null;
        "audio.gapless_v2" = null;
        "audio.loudness.environment" = null;
        "audio.normalize_v2" = false;
        "audio.play_bitrate_enumeration" = 4;
        "audio.play_bitrate_non_metered_enumeration" = 4;
        "audio.sync_bitrate_enumeration" = 4;
        "ui.minimize_to_tray" = true;
        "ui.track_os_notifications_enabled" = null;
      };
    };

    render = value:
      if builtins.isBool value
      then lib.boolToString value
      else if builtins.isString value
      then ''"${value}"''
      else toString value;

    pin = file: attrs: let
      drop = map (key: "-e ${lib.escapeShellArg "/^${lib.escapeRegex key}=/d"}") (lib.attrNames attrs);
      set = lib.mapAttrsToList (key: value: lib.escapeShellArg "${key}=${render value}") (lib.filterAttrs (_: value: value != null) attrs);
    in ''
      if [[ -f ${file} ]]; then
        sed -Ei ${toString drop} ${file}
        printf '%s\n' ${toString set} >>${file}
      fi
    '';

    enforce = pkgs.writeShellApplication {
      name = "spotify-prefs";
      runtimeInputs = [pkgs.gnused];
      text = ''
        config=''${XDG_CONFIG_HOME:-$HOME/.config}/spotify

        # no prefs yet means spotify's first run
        ${pin ''"$config/prefs"'' prefs.global}
        for user in "$config"/Users/*-user/prefs; do
          ${pin ''"$user"'' prefs.user}
        done
      '';
    };

    spotify = inputs.spicetify-nix.lib.mkSpicetify pkgs {
      enable = true;

      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        # must load first
        {
          src = pinSettings;
          name = "pinSettings.js";
        }
        hidePodcasts
        shuffle
        fullScreen
        sidebarCustomizer
        coverAmbience
        keyboardShortcut
        simpleBeautifulLyrics
        queueTime
        fullAlbumDate
        goToSong
        sleepTimer
      ];

      enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus
        newReleases
      ];

      enabledSnippets = with spicePkgs.snippets; [
        removeGradient
        removeTheArtistsAndCreditsSectionsFromTheSidebar
        removeBrowse
        hideScrollThroughPreviews
        modernScrollbar
        hideSidebarScrollbar
        fixMainViewWidth
        disableRecommendations
      ];
    };
  in {
    packages.spotify = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = spotify;
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}

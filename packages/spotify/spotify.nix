{inputs, ...}: {
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
  in {
    packages.spotify = inputs.spicetify-nix.lib.mkSpicetify pkgs {
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
  };
}

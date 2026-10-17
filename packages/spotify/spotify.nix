{inputs, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    spicePkgs = inputs'.spicetify-nix.legacyPackages;
  in {
    packages.spotify = inputs.spicetify-nix.lib.mkSpicetify pkgs {
      enable = true;

      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
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

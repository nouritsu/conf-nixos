{
  den.aspects.brave.nixos = {
    config,
    self',
    lib,
    ...
  }: let
    mkExtension = id: "${id};https://clients2.google.com/service/update2/crx";

    # shortcuts can't start with "@"; featured caps at three
    mkEngine = name: shortcut: url: {inherit name shortcut url;};

    brave = "brave-origin.desktop";
  in {
    imports = [
      {
        # per-host new tab page
        options.brave'.newTabPage = lib.mkOption {
          type = lib.types.str;
          default = "about:blank";
        };
      }
    ];

    environment.systemPackages = [self'.packages.brave];

    programs.chromium = {
      enable = true;

      extensions = [
        (mkExtension "mnjggcdmjocbbbhaepdhchncahnbgone") # SponsorBlock
        (mkExtension "eimadpbcbfnmbkopoojfekhnkhdbieeh") # Dark Reader
        (mkExtension "lnjaiaapbakfhlbjenjkhffcdpoompki") # Catppuccin file icons
        (mkExtension "ghmbeldphafepmbegfdlkpapadhbakde") # Proton Pass
        (mkExtension "bkkmolkhemgaeaeggcmfbghljjjoofoh") # Catppuccin Mocha theme
        # styles imported by hand: https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json
        (mkExtension "clngdbkpkpeebahjckkjfobafhncgmne") # Stylus
        (mkExtension "doojmbjmlfjjnbmnoijecmcbfeoakpjm") # NoScript
        (mkExtension "mdjildafknihdffpkfmmpnpoiajfjnjd") # Consent-O-Matic
        (mkExtension "ammoloihpcbognfddfjcljgembpibcmb") # JShelter
      ];

      extraOpts = {
        SiteSearchSettings = [
          (mkEngine "Wikipedia" "wiki" "https://en.wikipedia.org/w/index.php?title=Special:Search&search={searchTerms}")
          (mkEngine "YouTube" "yt" "https://www.youtube.com/results?search_query={searchTerms}")
          (mkEngine "NixOS Options" "no" "https://search.nixos.org/options?channel=unstable&query={searchTerms}")
          (mkEngine "Nix Packages" "np" "https://search.nixos.org/packages?channel=unstable&query={searchTerms}")
        ];

        PasswordManagerEnabled = false; # Proton Pass manages credentials

        # Chrome
        BookmarkBarEnabled = false;
        ShowHomeButton = false;
        NewTabPageLocation = config.brave'.newTabPage;
        BrowserLabsEnabled = false;
        SideSearchEnabled = false;
        BrowserAddPersonEnabled = false;
        BrowserGuestModeEnabled = false;

        # Nags
        BrowserSignin = 0;
        DefaultBrowserSettingEnabled = false;
        PromotionsEnabled = false;
        ShoppingListEnabled = false;
        TranslateEnabled = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;

        # Telemetry
        MetricsReportingEnabled = false;
        BraveP3AEnabled = false;
        BraveStatsPingEnabled = false;
        BraveWebDiscoveryEnabled = false;

        # Privacy
        DefaultBraveHttpsUpgradeSetting = 2; # https only
        WebRtcIPHandling = "default_public_interface_only";
        SearchSuggestEnabled = false;
        NetworkPredictionOptions = 2; # no preloading
      };
    };

    # not com.brave.Origin.desktop, which is NoDisplay
    xdg.mime.defaultApplications = {
      "text/html" = brave;
      "application/xhtml+xml" = brave;
      "x-scheme-handler/http" = brave;
      "x-scheme-handler/https" = brave;
      "x-scheme-handler/about" = brave;
      "x-scheme-handler/unknown" = brave;
    };

    environment.sessionVariables.BROWSER = "brave-origin";
  };

  # home assistant's overview dashboard, from nixos-srv
  den.aspects.brave.provides.home-assistant.nixos.brave'.newTabPage = "https://home.nouritsu.com/nix-overview/home";
}

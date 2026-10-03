{
  den.aspects.brave.nixos = {pkgs, ...}: let
    mkExtension = id: "${id};https://clients2.google.com/service/update2/crx";

    # shortcuts can't start with "@"; featured caps at three
    mkEngine = name: shortcut: url: {inherit name shortcut url;};

    brave = "brave-browser.desktop";
  in {
    environment.systemPackages = [pkgs.brave];

    programs.chromium = {
      enable = true;

      extensions = [
        (mkExtension "mnjggcdmjocbbbhaepdhchncahnbgone") # SponsorBlock
        (mkExtension "eimadpbcbfnmbkopoojfekhnkhdbieeh") # Dark Reader
        (mkExtension "lnjaiaapbakfhlbjenjkhffcdpoompki") # Catppuccin file icons
        (mkExtension "ghmbeldphafepmbegfdlkpapadhbakde") # Proton Pass
      ];

      extraOpts = {
        SiteSearchSettings = [
          (mkEngine "Wikipedia" "wiki" "https://en.wikipedia.org/w/index.php?title=Special:Search&search={searchTerms}")
          (mkEngine "YouTube" "yt" "https://www.youtube.com/results?search_query={searchTerms}")
          (mkEngine "NixOS Options" "no" "https://search.nixos.org/options?channel=unstable&query={searchTerms}")
          (mkEngine "Nix Packages" "np" "https://search.nixos.org/packages?channel=unstable&query={searchTerms}")
          (mkEngine "Home Manager Options" "hm" "https://home-manager-options.extranix.com/?query={searchTerms}&release=master")
        ];

        PasswordManagerEnabled = false; # Proton Pass manages credentials
        BookmarkBarEnabled = true;

        # Telemetry
        MetricsReportingEnabled = false;
        BraveP3AEnabled = false;
        BraveStatsPingEnabled = false;
        BraveWebDiscoveryEnabled = false;

        # Crypto, VPN, AI
        BraveRewardsDisabled = true;
        BraveWalletDisabled = true;
        BraveVPNDisabled = true;
        BraveAIChatEnabled = false;
      };
    };

    # not com.brave.Browser.desktop, which is NoDisplay
    xdg.mime.defaultApplications = {
      "text/html" = brave;
      "application/xhtml+xml" = brave;
      "x-scheme-handler/http" = brave;
      "x-scheme-handler/https" = brave;
      "x-scheme-handler/about" = brave;
      "x-scheme-handler/unknown" = brave;
    };

    environment.sessionVariables.BROWSER = "brave";
  };
}

{
  # Policies land in /etc/brave/policies/managed/ via programs.chromium, which
  # nixpkgs also points at Brave. stylix already owns that option (it writes
  # BrowserThemeColor there), so going through the module rather than
  # environment.etc keeps both sets merged into one policy file.
  den.aspects.brave.nixos = {pkgs, ...}: let
    # Force-installed add-ons; the Chrome Web Store update URL keeps them current.
    mkExtension = id: "${id};https://clients2.google.com/service/update2/crx";

    # Chromium site search entries. `shortcut` must not lead with "@" (Chromium
    # rejects it); typing it then Tab scopes the omnibox to that engine.
    # `featured` would move entries behind the omnibox "@" menu, but Chromium
    # caps that at three — leaving it off keeps all five reachable the same way.
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
        # Brave Search is already the built-in default, so no
        # DefaultSearchProvider* policy — setting one would only lock the
        # picker without changing which engine is used.
        SiteSearchSettings = [
          (mkEngine "Wikipedia" "wiki" "https://en.wikipedia.org/w/index.php?title=Special:Search&search={searchTerms}")
          (mkEngine "YouTube" "yt" "https://www.youtube.com/results?search_query={searchTerms}")
          (mkEngine "NixOS Options" "no" "https://search.nixos.org/options?channel=unstable&query={searchTerms}")
          (mkEngine "Nix Packages" "np" "https://search.nixos.org/packages?channel=unstable&query={searchTerms}")
          (mkEngine "Home Manager Options" "hm" "https://home-manager-options.extranix.com/?query={searchTerms}&release=master")
        ];

        PasswordManagerEnabled = false; # Proton Pass manages credentials
        BookmarkBarEnabled = true;

        # Chromium metrics plus Brave's own reporting.
        MetricsReportingEnabled = false;
        BraveP3AEnabled = false;
        BraveStatsPingEnabled = false;
        BraveWebDiscoveryEnabled = false;

        # Drop the bundled crypto/VPN/AI surface.
        BraveRewardsDisabled = true;
        BraveWalletDisabled = true;
        BraveVPNDisabled = true;
        BraveAIChatEnabled = false;
      };
    };

    # Default browser. brave-browser.desktop, not com.brave.Browser.desktop —
    # the latter is NoDisplay and exists only to match the portal app id.
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

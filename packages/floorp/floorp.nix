{
  perSystem = {pkgs, ...}: let
    # Floorp is a Firefox fork, so wrapFirefox + enterprise policies apply just
    # like upstream Firefox. floorp-bin-unwrapped is the (cached) prebuilt base.
    # Add-ons force-installed from addons.mozilla.org; the "latest" redirect
    # keeps them up to date.
    mkExtension = slug: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      installation_mode = "force_installed";
    };

    # Catppuccin Mocha / Mauve theme add-on (matches the system flavor + accent
    # set in modules/aspects/features/theme/catppuccin.nix).
    themeId = "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}";

    mkEngine = Name: Alias: URLTemplate: {
      inherit Name Alias URLTemplate;
      Method = "GET";
    };
  in {
    packages.floorp = pkgs.wrapFirefox pkgs.floorp-bin-unwrapped {
      extraPolicies = {
        ExtensionSettings = {
          "sponsorBlocker@ajay.app" = mkExtension "sponsorblock"; # SponsorBlock
          "addon@darkreader.org" = mkExtension "darkreader"; # Dark Reader
          "{bbb880ce-43c9-47ae-b746-c3e0096c5b76}" = mkExtension "catppuccin-web-file-icons"; # Catppuccin file icons
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = mkExtension "proton-pass"; # Proton Pass
          ${themeId} = mkExtension "catppuccin-mocha-mauve-git"; # Catppuccin Mocha Mauve theme
        };

        SearchEngines = {
          Default = "Brave Search";
          Add = [
            (mkEngine "Brave Search" "@brave" "https://search.brave.com/search?q={searchTerms}")
            (mkEngine "Wikipedia" "@wiki" "https://en.wikipedia.org/w/index.php?title=Special:Search&search={searchTerms}")
            (mkEngine "YouTube" "@yt" "https://www.youtube.com/results?search_query={searchTerms}")
            (mkEngine "NixOS Options" "@no" "https://search.nixos.org/options?channel=unstable&query={searchTerms}")
            (mkEngine "Nix Packages" "@np" "https://search.nixos.org/packages?channel=unstable&query={searchTerms}")
            (mkEngine "Home Manager Options" "@hm" "https://home-manager-options.extranix.com/?query={searchTerms}&release=master")
          ];
        };

        PasswordManagerEnabled = false; # Proton Pass manages credentials
        DisplayBookmarksToolbar = "always";

        # Trim browser bloat.
        DisableTelemetry = true;
        DisablePocket = true;
      };

      # Activate the Catppuccin theme force-installed above.
      extraPrefs = ''
        lockPref("extensions.activeThemeID", "${themeId}");
      '';
    };
  };
}

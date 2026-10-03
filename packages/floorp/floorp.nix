{
  perSystem = {pkgs, ...}: let
    mkExtension = slug: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      installation_mode = "force_installed";
    };

    themeId = "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}";

    mkEngine = Name: Alias: URLTemplate: {
      inherit Name Alias URLTemplate;
      Method = "GET";
    };
  in {
    packages.floorp = pkgs.wrapFirefox pkgs.floorp-bin-unwrapped {
      extraPolicies = {
        ExtensionSettings = {
          "sponsorBlocker@ajay.app" = mkExtension "sponsorblock";
          "addon@darkreader.org" = mkExtension "darkreader";
          "{bbb880ce-43c9-47ae-b746-c3e0096c5b76}" = mkExtension "catppuccin-web-file-icons";
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = mkExtension "proton-pass";
          ${themeId} = mkExtension "catppuccin-mocha-mauve-git";
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

        # Bloat
        DisableTelemetry = true;
        DisablePocket = true;
      };

      extraPrefs = ''
        lockPref("extensions.activeThemeID", "${themeId}");
      '';
    };
  };
}

{pkgs, ...}: {
  programs.firefox = {
    enable = true;

    profiles.default = {
      name = "default";
      search = {
        default = "ddg";
        engines = {
          wiki = {
            name = "Wikipedia";
            urls = [{template = "https://en.wikipedia.org/w/index.php?title=Special:Search&search={searchTerms}";}];
            icon = "https://en.wikipedia.org/favicon.ico";
            definedAliases = ["@wiki"];
          };

          yt = {
            name = "YouTube";
            urls = [{template = "https://www.youtube.com/results?search_query={searchTerms}";}];
            icon = "https://www.youtube.com/favicon.ico";
            definedAliases = ["@yt" "@youtube"];
          };

          nix-packages = {
            name = "Nix Package Search";
            urls = [{template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };

          nix-options = {
            name = "Nix Options Search";
            urls = [{template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };

          hm-options = {
            name = "Home Manager Options Search";
            urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@hm"];
          };
        };
      };
    };
  };
}

{
  den.aspects.aneesh.homeManager = {pkgs, ...}: {
    # old app-core (HM half)
    programs.man = {
      enable = true;
      generateCaches = true;
    };

    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
        proc_tree = true;
        proc_gradient = false;
        update_ms = 1000;
      };
    };

    programs.tealdeer = {
      enable = true;
      settings.updates = {
        auto_update = true;
        auto_update_interval_hours = 24;
      };
    };

    # old app-fish (HM half): plugins
    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge.src;
        }
        {
          name = "humantime-fish";
          src = pkgs.fishPlugins.humantime-fish.src;
        }
        {
          name = "colored-man-pages";
          src = pkgs.fishPlugins.colored-man-pages.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
    };
  };
}

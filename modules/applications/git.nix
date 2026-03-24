{
  flake = {
    nixosModules = {
      app-git = {...}: {
        my.hmModules = ["app-git"];
        programs.git.enable = true;
      };

      app-gh = {...}: {
        my.hmModules = ["app-gh"];
      };

      app-jujutsu = {...}: {
        my.hmModules = ["app-jujutsu"];
      };

      app-delta = {...}: {
        my.hmModules = ["app-delta"];
      };
    };

    homeModules = {
      app-gh = {pkgs, ...}: {
        programs.gh = {
          enable = true;
          extensions = [
            pkgs.gh-markdown-preview
            pkgs.gh-poi
            pkgs.gh-f
          ];
        };

        programs.gh-dash.enable = true;
      };

      app-git = {pkgs, ...}: {
        programs.git.enable = true;
        programs.git.settings.user = {
          user = "Aneesh Bhave";
          email = "aneesh1701@gmail.com";
        };

        programs.lazygit.enable = true;

        programs.fish.plugins = [
          {
            name = "forgit";
            src = pkgs.fishPlugins.forgit.src;
          }
        ];

        programs.delta.enableGitIntegration = true;
      };

      app-jujutsu = {...}: {
        programs.jujutsu.enable = true;
        programs.jujutsu.settings = {
          user = "Aneesh Bhave";
          email = "aneesh1701@gmail.com";
        };

        programs.jjui.enable = true;
        programs.fish.shellAliases = {
          lazyjj = "jjui";
        };

        programs.delta.enableJujutsuIntegration = true;
      };

      app-delta = {...}: {
        programs.delta.enable = true;
      };
    };
  };
}

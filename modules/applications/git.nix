{self, ...}: {
  flake = {
    nixosModules = {
      app-git = {...}: {
        home-manager.users.aneesh.imports = [self.homeModules.app-git];
        programs.git.enable = true;
      };

      app-gh = {...}: {
        home-manager.users.aneesh.imports = [self.homeModules.app-gh];
      };

      app-jujutsu = {...}: {
        home-manager.users.aneesh.imports = [self.homeModules.app-jujutsu];
      };

      app-delta = {...}: {
        home-manager.users.aneesh.imports = [self.homeModules.app-delta];
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

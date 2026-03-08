{self, ...}: {
  flake = {
    nixosModules.app-fish = {pkgs, ...}: {
      my.hmModules = ["app-fish"];

      programs.fish.enable = true;
      users.defaultUserShell = pkgs.fish;
      environment.systemPackages = [pkgs.fish-lsp pkgs.any-nix-shell];

      programs.fish.interactiveShellInit =
        /*
        fish
        */
        ''
          set fish_greeting
          any-nix-shell fish --info-right | source
        '';
    };

    homeModules.app-fish = {pkgs, ...}: {
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
  };
}

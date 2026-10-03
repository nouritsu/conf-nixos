{
  den.aspects.shell.nixos = {
    self',
    pkgs,
    ...
  }: {
    environment.systemPackages = [
      self'.packages.btop
      self'.packages.tealdeer

      pkgs.fishPlugins.done
      pkgs.fishPlugins.autopair
      pkgs.fishPlugins.sponge
      pkgs.fishPlugins.humantime-fish
      pkgs.fishPlugins.colored-man-pages
      pkgs.fishPlugins.fzf-fish
    ];
  };

  den.aspects.shell.homeManager = {
    programs.man = {
      enable = true;
      generateCaches = true;
    };

    # keep on: its config.fish sources hm-session-vars for the niri session
    programs.fish.enable = true;
  };
}

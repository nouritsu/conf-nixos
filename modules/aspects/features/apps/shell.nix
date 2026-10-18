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

    # native fish instead of fenv spawning bash at every start
    programs.fish.useBabelfish = true;

    # apropos and man -k; indexed by a service, not on every rebuild
    documentation.man.cache = {
      enable = true;
      generateAtRuntime = true;
    };
  };
}

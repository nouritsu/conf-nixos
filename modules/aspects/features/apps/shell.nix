{
  den.aspects.shell.nixos = {
    self',
    pkgs,
    ...
  }: {
    environment.systemPackages = [
      self'.packages.btop
      self'.packages.tealdeer

      # buildFishPlugin packages land in share/fish/vendor_*.d, which NixOS
      # fish loads from the system profile; no plugin manager needed
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

    # Holds no config, but must stay on. niri-session re-execs through the
    # fish login shell, and the config.fish this generates is what sources
    # hm-session-vars into the graphical session: GLAMOUR_STYLE and the
    # cursor theme. There is no ~/.profile to fall back on.
    programs.fish.enable = true;
  };
}

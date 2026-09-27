{den, ...}: {
  den.aspects.ai = {
    includes = [(den.batteries.unfree ["cursor"])];
    nixos = {
      self',
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        self'.packages.opencode
        self'.packages.claude-code
        pkgs.code-cursor

        pkgs.ccusage
        pkgs.claude-monitor
        pkgs.claude-mergetool
      ];

      # what `claude-mergetool install git` would write, but the user config
      # is home-manager's and read-only; lands in /etc/gitconfig alongside the
      # package instead. Use with `git mergetool --tool=claude`.
      programs.git = {
        enable = true;
        config.mergetool.claude = {
          cmd = ''claude-mergetool merge "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'';
          trustExitCode = true;
        };
      };

      programs.fish.shellAbbrs = {
        oc = "opencode";
        c = "claude";
      };
      programs.fish.shellAliases.claude-usage = "ccusage";
    };
  };
}

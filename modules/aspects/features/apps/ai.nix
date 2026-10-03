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

      # claude-mergetool install git can't write the wrapped gitconfig
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

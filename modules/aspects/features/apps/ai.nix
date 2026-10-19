{den, ...}: {
  den.aspects.ai = {
    includes = [(den.batteries.unfree ["cursor"])];
    nixos = {
      self',
      inputs',
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        self'.packages.opencode
        self'.packages.claude-code
        inputs'.claude-desktop.packages.claude-desktop
        pkgs.code-cursor

        pkgs.ccusage
        pkgs.claude-monitor
        pkgs.claude-mergetool
      ];

      # electron doesn't know niri and falls back to plaintext
      environment.sessionVariables.CLAUDE_PASSWORD_STORE = "gnome-libsecret";

      # desktop runs its own claude without the wrapper's --settings; managed
      # settings reach every claude. statusLine is tui-only, desktop notifies itself
      environment.etc."claude-code/managed-settings.json".text = let
        inherit (self'.packages.claude-code.configuration) settings;
      in
        builtins.toJSON {
          inherit (settings) attribution permissions;
          hooks = {inherit (settings.hooks) PostToolUse;};
        };

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
        cr = "claude --resume";
        cn = "claude --continue";
      };
      programs.fish.shellAliases.claude-usage = "ccusage";
    };
  };
}

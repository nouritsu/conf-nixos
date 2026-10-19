{den, ...}: {
  den.aspects.ai = {
    includes = [(den.batteries.unfree ["cursor"])];
    nixos = {
      self',
      inputs',
      pkgs,
      lib,
      ...
    }: let
      desktop = inputs'.claude-desktop.packages.claude-desktop;

      # chat tab servers; the app rewrites this file, so they merge in at launch
      chatMcp = pkgs.writeText "claude-desktop-mcp.json" (builtins.toJSON {
        mcpServers = {
          nixos.command = lib.getExe pkgs.mcp-nixos;
          context7.command = lib.getExe' pkgs.context7-mcp "context7-mcp";
        };
      });

      # no meta: its unfree licence would trip this pkgs' check, the flake allows it
      claude-desktop = pkgs.symlinkJoin {
        inherit (desktop) name;
        paths = [
          (pkgs.writeShellApplication {
            name = "claude-desktop";
            runtimeInputs = [pkgs.jq pkgs.coreutils];
            text = ''
              conf=''${XDG_CONFIG_HOME:-$HOME/.config}/Claude/claude_desktop_config.json
              mkdir -p "$(dirname "$conf")"
              [ -f "$conf" ] || echo '{}' > "$conf"
              if ! jq -e --slurpfile pin ${chatMcp} '. * $pin[0] == .' "$conf" > /dev/null; then
                tmp=$(mktemp "$conf.XXXXXX")
                if jq --slurpfile pin ${chatMcp} '. * $pin[0]' "$conf" > "$tmp"; then
                  mv "$tmp" "$conf"
                else
                  rm -f "$tmp"
                fi
              fi
              exec ${desktop}/bin/claude-desktop "$@"
            '';
          })
          desktop
        ];
      };
    in {
      environment.systemPackages = [
        self'.packages.opencode
        self'.packages.claude-code
        claude-desktop
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

          # read in place through the /etc link, so a switch updates it
          extraKnownMarketplaces.nixos-config.source = {
            source = "directory";
            path = "/etc/claude-code/marketplace";
          };
          enabledPlugins = {
            "nix@nixos-config" = true;
            "qt-development-skills@claude-plugins-official" = true;
          };
        };

      environment.etc."claude-code/marketplace".source = self'.packages.claude-marketplace;

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

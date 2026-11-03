{inputs, ...}: let
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
  c = slot: "#${palette.${slot}}";
in {
  den.aspects.tuios.nixos = {
    self',
    config,
    pkgs,
    lib,
    ...
  }: let
    tuios = lib.getExe pkgs.tuios;
    wezterm = lib.getExe self'.packages.wezterm;

    # the machines of this config, each listing the others
    machines = {
      pc = "pc.local";
      laptop = "laptop.local";
    };

    # read-only, so tuios writes in-app changes to local.toml, which can't override these
    settings = (pkgs.formats.toml {}).generate "tuios-config.toml" {
      include = ["?local.toml"];

      startup = {
        daemon = true;
        tiled = true;
        layout = "scrolling";
        start_in_terminal_mode = true;
      };

      appearance = {
        theme = "catppuccin-mocha-mauve";
        auto_enter_terminal_on_focus = "all";
        click_to_type = "single";
        hide_window_buttons = true;
        dockbar_position = "bottom";
        dim_unfocused = 20;
        sidebar.enabled = false;
        selection = {
          cursor_bg = c "base0E";
          cursor_fg = c "base00";
          match_bg = c "base0E";
          match_fg = c "base00";
          search_bg = c "base04";
          search_fg = c "base05";
        };
      };

      # only the leader is taken, everything else reaches the pane
      keybindings = {
        leader_key = "ctrl+space";
        lock = true;
        command = [
          {
            key = "prefix+alt+s";
            type = "popup";
            description = "Open a project";
            command = ''dir=$(${lib.getExe pkgs.fd} --type d --max-depth 1 . ~/Projects | ${self'.packages.television}/bin/tv --no-status-bar) && [ -n "$dir" ] && ${tuios} switch-session --create --cwd "$dir" "$(basename "$dir")"'';
          }
        ];
      };

      # claude-notify sends the desktop ones
      notifications.agent.notify = false;

      hosts = lib.mapAttrs (_: addr: {
        inherit addr;
        command = "/run/current-system/sw/bin/tuios";
      }) (removeAttrs machines [config.networking.hostName]);
    };

    theme = pkgs.writeText "catppuccin-mocha-mauve.json" (builtins.toJSON {
      id = "catppuccin-mocha-mauve";
      display_name = "Catppuccin Mocha Mauve";
      base = "catppuccin_mocha";
      chrome = {
        accent = c "base0E";
        accent_bright = c "base0E";
      };
    });
  in {
    environment.systemPackages = [pkgs.tuios];

    environment.etc."tuios/config.toml".source = settings;
    environment.etc."tuios/catppuccin-mocha-mauve.json".source = theme;

    systemd.user.tmpfiles.rules = [
      "L+ %h/.config/tuios/config.toml - - - - /etc/tuios/config.toml"
      "L+ %h/.config/tuios/themes/catppuccin-mocha-mauve.json - - - - /etc/tuios/catppuccin-mocha-mauve.json"
      "f %h/.config/tuios/local.toml - - - -"
    ];

    # else the first tuios started, devenv shell and all, lends every pane its env
    systemd.user.services.tuios = {
      description = "tuios daemon";
      wantedBy = ["graphical-session.target"];
      # no partOf: panes outlive a niri restart
      after = ["graphical-session.target"];
      # panes need the session PATH
      enableDefaultPath = false;
      serviceConfig = {
        ExecStart = "${tuios} daemon";
        # SIGTERM to the daemon alone, so its last save still sees the shells' cwds
        KillMode = "mixed";
        # a daemon already running exits 1 and is left alone
        Restart = "on-abnormal";
      };
    };

    which-key'.menu.t.submenu.t = {
      desc = "tuios";
      icon = "ebc8";
      cmd = "${wezterm} start --class tuios -- ${tuios} attach main -c";
      app-id = "^tuios$";
    };

    programs.fish.shellAbbrs = {
      t = "tuios";
      ta = "tuios attach";
      tl = "tuios ls";
      tk = "tuios kill-session";
    };

    # ssh logins land in the desktop's session; detaching drops back here
    programs.fish.interactiveShellInit = lib.mkAfter ''
      if set -q SSH_CONNECTION; and not set -q TUIOS_SESSION; and status is-login
        tuios attach main -c
      end
    '';
  };
}

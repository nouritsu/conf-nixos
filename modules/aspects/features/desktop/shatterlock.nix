{
  den.aspects.shatterlock = {
    nixos = {
      config,
      self',
      pkgs,
      lib,
      ...
    }: {
      imports = [
        {
          # per-host settings, merged with the shared ones below
          options.shatterlock'.settings = lib.mkOption {
            inherit (pkgs.formats.json {}) type;
            default = {};
          };
        }
      ];

      shatterlock'.settings = {
        # material preset, under the keys below
        style = "material";
        # fallback lock; dux ignores loginctl lock-session with logind integration off
        actionDefs.lock.command = ["dms" "ipc" "call" "lock" "lock"];
        # seconds; dux lock timeouts stay 0
        lock.idle = {
          ac = 3600;
          battery = 600;
        };
        # needs the patched niri and its layer rule
        live = true;
      };

      environment.etc."shatterlock/settings.json".source =
        (pkgs.formats.json {}).generate "shatterlock-settings.json" config.shatterlock'.settings;

      # refuses to lock without its pam service
      security.pam.services.shatterlock = {};

      # the daemon reads its settings only at start
      system.userActivationScripts.shatterlock-reload.text = "${lib.getExe self'.packages.shatterlock} reload || true";
    };

    provides.desktop.nixos = {
      pkgs,
      lib,
      ...
    }: let
      toWindows = pkgs.writeShellApplication {
        name = "reboot-to-windows";
        runtimeInputs = [pkgs.efibootmgr pkgs.gnused];
        text = ''
          entry=$(efibootmgr | sed -n 's/^Boot\([0-9A-Fa-f]\{4\}\)\*\{0,1\} Windows Boot Manager.*/\1/p' | head -n1)
          /run/wrappers/bin/pkexec ${lib.getExe pkgs.efibootmgr} --bootnext "$entry" > /dev/null
          systemctl reboot
        '';
      };
    in {
      shatterlock'.settings = {
        actions = ["lock" "logout" "restart" "windows" "shutdown" "firmware"];
        # vanish first, so the polkit prompt isn't under the rift
        actionDefs.windows = {
          label = "Windows";
          icon = "desktop_windows";
          key = "W";
          confirm = "hold";
          color = "";
          command = [(lib.getExe toWindows)];
          after = "vanish";
          status = "";
          requires = "";
        };
        # faster opens
        idle = "mapped";
      };
    };

    provides.laptop.nixos.shatterlock'.settings.actions = [
      "lock"
      "suspend"
      "hibernate"
      "logout"
      "restart"
      "shutdown"
    ];
  };
}

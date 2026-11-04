{
  den.aspects.nirinit.nixos = {
    self',
    pkgs,
    lib,
    ...
  }: let
    wezterm = lib.getExe self'.packages.wezterm;

    # started at login already, or restore themselves
    skip = [
      "steam"
      "vesktop"
      "com.github.wwmm.easyeffects"
      "proton.vpn.app.gtk"
      ".protonvpn-app-wrapped"
    ];

    # a notification listing what would reopen; body or Restore restores, dismissed or
    # unanswered for 10 min starts fresh, no notification server restores
    ask = pkgs.writeShellApplication {
      name = "nirinit-ask";
      runtimeInputs = [pkgs.libnotify pkgs.glib pkgs.jq];
      # jq sees its own $vars
      excludeShellChecks = ["SC2016"];
      text = ''
        session=''${XDG_DATA_HOME:-$HOME/.local/share}/nirinit/session.json
        summary=$(jq -r --argjson skip '${builtins.toJSON skip}' '
          [.[] | .app_id // empty | select(IN($skip[]) | not) | split(".") | last]
          | group_by(.) | map(if length > 1 then "\(length)× \(.[0])" else .[0] end) | join(", ")
        ' "$session" 2> /dev/null) || summary=
        if [[ -z $summary ]]; then
          exit 1
        fi

        gdbus wait --session --timeout 60 org.freedesktop.Notifications || exit 0

        # critical: it stays up until answered, and shows through do not disturb
        exec {answer}< <(notify-send --app-name=nirinit --icon=edit-undo-history --urgency=critical --print-id --wait \
          --action=restore=Restore --action=fresh="Start fresh" "Restore last session?" "$summary")
        read -r id <&"$answer" || exit 0
        if read -r -t 600 action <&"$answer"; then
          test "$action" = restore
          exit
        fi
        gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications \
          --method org.freedesktop.Notifications.CloseNotification "$id" > /dev/null || true
        exit 1
      '';
    };

    settings = (pkgs.formats.toml {}).generate "nirinit.toml" {
      skip.apps = skip;
      launch = {
        tuios = "${wezterm} start --class tuios -- ${lib.getExe pkgs.tuios} attach main -c";
        btop = "${wezterm} start --class btop -- ${lib.getExe self'.packages.btop}";
        # its directory and full-screen program, by the window's old id
        "org.wezfurlong.wezterm" = lib.getExe self'.packages.wezterm-restore;
      };
      ask = lib.getExe ask;
    };
  in {
    # asks to restore the last saved layout once per niri session, then keeps it saved
    systemd.user.services.nirinit = {
      description = "niri session save and restore";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${lib.getExe self'.packages.nirinit} --config ${settings} --save-interval 30";
        Restart = "always";
        PrivateTmp = true;
      };
    };
  };
}

{
  den.aspects.catppuccin.provides.steam.nixos = {
    pkgs,
    lib,
    ...
  }: let
    adwaita-for-steam = pkgs.fetchFromGitHub {
      owner = "tkashkin";
      repo = "Adwaita-for-Steam";
      rev = "4.4";
      hash = "sha256-wH0z2LZ94j5ErRI40f9IRBJXJ6yuL+NLgjmj9G8odxU=";
    };

    args = [
      "--color-theme"
      "catppuccin-mocha"
      "--accent-color"
      "#cba6f7"
      "--color-scheme"
      "dark"
    ];

    patched = ["library" "gamerecording" "gamenotes"];
  in {
    # Steam updates restore its stock css
    systemd.user.paths.steam-theme = {
      wantedBy = ["default.target"];
      pathConfig.PathChanged = map (f: "%h/.local/share/Steam/steamui/css/${f}.css") patched;
    };

    systemd.user.services.steam-theme = {
      description = "Patch Steam with Adwaita for Steam in catppuccin mocha";
      wantedBy = ["default.target"];
      serviceConfig.Type = "oneshot";
      path = [pkgs.python3 pkgs.coreutils];
      script = ''
        steam=$HOME/.local/share/Steam
        stamp=$steam/steamui/adwaita/nix-stamp
        want=${lib.escapeShellArg "${adwaita-for-steam} ${toString args}"}
        [ -d "$steam/steamui/css" ] || exit 0

        current=1
        for f in ${toString patched}; do
          [ "$(head -c 23 "$steam/steamui/css/$f.css" 2>/dev/null)" = "/* Adwaita-for-Steam */" ] || current=
        done
        if [ -n "$current" ] && [ "$(cat "$stamp" 2>/dev/null)" = "$want" ]; then
          exit 0
        fi

        # the installer copies its own tree into Steam, so it can't run read-only
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        cp -r --no-preserve=mode ${adwaita-for-steam}/. "$tmp"
        cd "$tmp"
        python3 install.py --target "$steam" ${lib.escapeShellArgs args}
        printf '%s' "$want" > "$stamp"
      '';
    };
  };
}

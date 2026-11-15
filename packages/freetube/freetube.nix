{inputs, ...}: let
  inherit (inputs) wrappers;
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
  c = slot: "#${palette.${slot}}";
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    autoSkip = color: {
      inherit color;
      skip = "autoSkip";
    };

    settings = {
      baseTheme = "catppuccinMocha";
      mainColor = "CatppuccinMochaMauve";
      secColor = "CatppuccinMochaMauve";
      # the wrapped mpv from PATH, with its own sponsorblock and uosc
      externalPlayer = "mpv";

      # less clutter
      hideSubscriptionsShorts = true;
      hideChannelShorts = true;
      hideTrendingVideos = true;
      hidePopularVideos = true;
      showDistractionFreeTitles = true;

      # playback
      defaultQuality = "1440";
      enableSubtitlesByDefault = false;
      autoplayVideos = true;
      playNextVideo = true;

      # housekeeping
      checkForUpdates = false;
      useRssFeeds = true;
      backendFallback = true;

      # sponsorblock + dearrow; colours are freetube's defaults
      useSponsorBlock = true;
      sponsorBlockSponsor = autoSkip "Green";
      sponsorBlockSelfPromo = autoSkip "Yellow";
      sponsorBlockInteraction = autoSkip "Pink";
      sponsorBlockIntro = autoSkip "Cyan";
      sponsorBlockOutro = autoSkip "Blue";
      useDeArrowTitles = true;
      useDeArrowThumbnails = true;
    };

    # nedb lines; the last line per _id wins and freetube compacts the file on load
    settingsLines = pkgs.writeText "freetube-settings.db" (lib.concatMapAttrsStringSep "\n" (id: value:
        builtins.toJSON {
          _id = id;
          inherit value;
        })
      settings
      + "\n");

    # matched by id, then by name; subscriptions stay in the app
    profiles = pkgs.writeText "freetube-profiles.json" (builtins.toJSON (map (p: p // {textColor = c "base00";}) [
      {
        _id = "allChannels";
        name = "All Channels";
        bgColor = c "base0E";
      }
      {
        _id = "music";
        name = "Music";
        bgColor = c "base08";
      }
      {
        _id = "gaming";
        name = "Gaming";
        bgColor = c "base0B";
      }
      {
        _id = "tech";
        name = "Tech";
        bgColor = c "base0D";
      }
      {
        _id = "learning";
        name = "Learning";
        bgColor = c "base09";
      }
      {
        _id = "stand-up";
        name = "Stand Up";
        bgColor = c "base0A";
      }
      {
        _id = "entertainment";
        name = "Entertainment";
        bgColor = c "base0C";
      }
    ]));

    enforce = pkgs.writeShellApplication {
      name = "freetube-pin-settings";
      runtimeInputs = [pkgs.coreutils pkgs.jq];
      text = ''
        dir=''${XDG_CONFIG_HOME:-$HOME/.config}/FreeTube
        mkdir -p "$dir"
        cat ${settingsLines} >>"$dir/settings.db"

        db=$dir/profiles.db
        touch "$db"
        changed=$(jq -cn --slurpfile want ${profiles} '
          (reduce inputs as $l ({};
            if $l."$$deleted" then del(.[$l._id])
            elif $l._id then .[$l._id] = $l
            else . end)) as $have
          | $want[0][]
          | . as $p
          | ($have[$p._id] // first($have[] | select(.name == $p.name)) // {_id: $p._id, subscriptions: []}) as $old
          | $old + $p | ._id = $old._id
          | select(. != $old)
        ' "$db")
        [[ -z $changed ]] || printf '%s\n' "$changed" >>"$db"
      '';
    };
  in {
    packages.freetube = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.freetube;
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}

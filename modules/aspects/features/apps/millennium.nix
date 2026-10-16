{
  den.aspects.extra.provides.millennium.nixos = {
    pkgs,
    lib,
    ...
  }: let
    jq = lib.getExe pkgs.jq;

    release = repo: asset: args:
      pkgs.fetchzip ({url = "https://github.com/${repo}/releases/download/${asset}";} // args);

    # no releases; built the way the plugin store builds it, at the commit the store pins
    sortium = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "sortium";
      version = "1.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "SalvadorCorreia";
        repo = "Sortium";
        rev = "d6a286c51cdbb10765606d0e92fb35b3e14216fa";
        hash = "sha256-E2xj0LWE9YowMquJx47aCAjxBj0cdUrYf9r0nfbvBCA=";
      };
      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = pkgs.pnpm_10;
        fetcherVersion = 4;
        hash = "sha256-JX8Xfzr28e5Vm4bvWIwaZKAgVWOzjvtBH54eHx6mUk8=";
      };
      nativeBuildInputs = [pkgs.nodejs pkgs.pnpmConfigHook pkgs.pnpm_10];
      buildPhase = ''
        runHook preBuild
        pnpm run build
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r .millennium backend plugin.json $out
        runHook postInstall
      '';
    });

    # plugin packer, prebuilt in the npm package
    starlight = pkgs.stdenv.mkDerivation {
      pname = "starlight";
      version = "1.1.4";
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@steambrew/starlight/-/starlight-1.1.4.tgz";
        hash = "sha512-shd8fd/p53RJIwg/i/6y2aueEQVuPW1u5oGKlJIm+aco2B2g0wObIoZxdfdp1t3dBRfZ/4GwH3LcfoaHLla+5Q==";
      };
      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.stdenv.cc.cc.lib];
      installPhase = "install -Dm755 binaries/starlight-linux-x64 $out/bin/starlight";
    };

    # not in the plugin store; its only release is a rolling `latest` asset
    steam-native-notifications = pkgs.stdenvNoCC.mkDerivation {
      pname = "steam-native-notifications";
      version = "0.1.0-unstable-2026-09-10";
      src = pkgs.fetchFromGitHub {
        owner = "tyvsmith";
        repo = "steam-native-notifications";
        rev = "1ad10344ff163521b2190107fdda0c9199f2ffd1";
        hash = "sha256-Tl4WdROZrYzISA39kvbkNEOdtsLjTRGGF1NjdYxQAZ8=";
      };
      nativeBuildInputs = [starlight];
      buildPhase = ''
        runHook preBuild
        mkdir dist
        starlight pack -o dist
        runHook postBuild
      '';
      # single-file output
      installPhase = ''
        runHook preInstall
        cp dist/*.star $out
        runHook postInstall
      '';
      dontFixup = true;
    };

    # folder = plugin.json name, file = <id>.star
    plugins = pkgs.linkFarm "millennium-plugins" {
      inherit sortium;
      "me.tysmith.steam-native-notifications.star" = steam-native-notifications;
      achievement-groups = release "BossSloth/SteamHunter-plugin" "v2.1.0/Achievement-Groups-plugin-2.1.0.zip" {
        hash = "sha256-Lu7ORsn9uRRb83FkbBOxH137ulJyohgwmqqvzJlqAx8=";
      };
      extendium = release "BossSloth/Extendium" "v2.0.4/extendium-2.0.4.zip" {
        hash = "sha256-ecchVQE6Syk+WJt+jMs1ZHk254Z/Gl2JArajsnyB26Q=";
      };
      global_launch_options = release "BlafKing/steam-global-launch-options" "v1.1.0/steam-global-launch-options.zip" {
        hash = "sha256-0OnTDvHeT5f1an0gil3mbgneV7PHULyMj/UgBhmhoZk=";
      };
      hltb-for-millennium = release "jcdoll/hltb-millennium-plugin" "v2.2.0/hltb-for-millennium-2.2.0.zip" {
        hash = "sha256-LH9JzLHSIOgJcasPEsFwQkninysyyzty37xDnFv0m/g=";
      };
      protondb-library-badges = release "Yohlo/protondb-library-badges" "v1.0.1/protondb-library-badges-v1.0.1.zip" {
        hash = "sha256-TvHxDWimhL+/4vjHLeNLTy+1kfrQiK1nEKgaayV7JQo=";
      };
      size-on-disk = release "k0d13/steam-size-on-disk" "v1.2.0/size-on-disk-1.2.0.zip" {
        hash = "sha256-uEoNS5rYUblax0+eCG8B6zHt3XIoDdQFqzt3PxhamCc=";
        stripRoot = false;
      };
      # no releases; the dev build of the commit the plugin store pins
      steam-easygrid = release "luthor112/steam-easygrid" "dev-3be3c47ec244d722393be79a6868c35688672c22/steam-easygrid.zip" {
        hash = "sha256-SyPQhmNKYp0jEEMdEID5pfFuO0kQZtrWnF1Zvf/Hnfg=";
        stripRoot = false;
      };
    };

    # folder = theme id in the config
    themes = pkgs.linkFarm "millennium-themes" {
      Adwaita-for-Steam = pkgs.fetchFromGitHub {
        owner = "tkashkin";
        repo = "Adwaita-for-Steam";
        rev = "4.4";
        hash = "sha256-wH0z2LZ94j5ErRI40f9IRBJXJ6yuL+NLgjmj9G8odxU=";
      };
    };

    # merged into Millennium's config; its Purple in Catppuccin Mocha is mauve
    settings.themes = {
      activeTheme = "Adwaita-for-Steam";
      conditions.Adwaita-for-Steam = {
        "Color theme" = "Catppuccin Mocha";
        "Color scheme" = "Dark";
        "Accent color" = "Purple";
      };
    };
  in {
    # runs inside the FHS env before every Steam start
    programs.steam.package = pkgs.millennium-steam.override {
      extraProfile = ''
        (
          sync() {
            for link in "$1"/*; do
              src=$(readlink -f "$link")
              dst=$2/$(basename "$link")
              # .star plugins are never unpacked or written to
              if [ -f "$src" ]; then
                ln -sf "$src" "$dst"
                continue
              fi
              [ "$(cat "$dst/.nix-source" 2>/dev/null)" = "$src" ] && continue

              # copied, not linked: plugins keep their cache and settings next to their code
              mkdir -p "$dst"
              cp -rT --no-preserve=mode,ownership "$src" "$dst"
              # Millennium's updater keys on this; versions come from here
              rm -f "$dst/metadata.json"
              printf '%s' "$src" > "$dst/.nix-source"
            done
          }

          sync ${plugins} "''${XDG_DATA_HOME:-$HOME/.local/share}/millennium/plugins"
          # themes live under this link, which Steam makes on its first start
          [ -d "$HOME/.steam/steam" ] && sync ${themes} "$HOME/.steam/steam/millennium/themes"

          # only once Millennium has written its config
          cfg=''${XDG_CONFIG_HOME:-$HOME/.config}/millennium/config.json
          want=${lib.escapeShellArg (builtins.toJSON settings)}
          if [ -f "$cfg" ] && ! ${jq} -e --argjson want "$want" '. * $want == .' "$cfg" >/dev/null; then
            new=$(${jq} --argjson want "$want" '. * $want' "$cfg") && printf '%s\n' "$new" > "$cfg"
          fi
        ) || true

        # stock Steam without a rebuild; the bootstrap is relinked on the next normal start
        if [ -n "''${STEAM_NO_MILLENNIUM-}" ]; then
          rm -f "$HOME/.local/share/Steam/ubuntu12_32/libXtst.so.6" "$HOME/.local/share/Steam/ubuntu12_64/libXtst.so.6"
        fi
      '';
    };

    # steam-native-notifications shells out to these
    programs.steam.extraPackages = [pkgs.curl pkgs.libnotify];

    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "steam-no-millennium";
        desktopName = "Steam (no Millennium)";
        exec = "env STEAM_NO_MILLENNIUM=1 steam %U";
        icon = "steam";
        categories = ["Game"];
      })
    ];
  };
}

{
  perSystem = {pkgs, ...}: let
    release = {
      url,
      hash,
      stripRoot ? true,
      ...
    } @ args:
      pkgs.srcOnly (removeAttrs args ["url" "hash" "stripRoot"]
        // {
          stdenv = pkgs.stdenvNoCC;
          src = pkgs.fetchzip {inherit url hash stripRoot;};
        });

    # plugin packer, prebuilt in the npm package
    starlight = pkgs.stdenv.mkDerivation rec {
      pname = "starlight";
      version = "1.1.4";
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@steambrew/starlight/-/starlight-${version}.tgz";
        hash = "sha512-shd8fd/p53RJIwg/i/6y2aueEQVuPW1u5oGKlJIm+aco2B2g0wObIoZxdfdp1t3dBRfZ/4GwH3LcfoaHLla+5Q==";
      };
      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.stdenv.cc.cc.lib];
      installPhase = "install -Dm755 binaries/starlight-linux-x64 $out/bin/starlight";
      passthru.nup = [];
    };
  in {
    packages.starlight = starlight;

    # no releases; built the way the plugin store builds it, at the commit the store pins
    packages.millennium-sortium = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
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

    # not in the plugin store; its only release is a rolling `latest` asset
    packages.millennium-steam-native-notifications = pkgs.stdenvNoCC.mkDerivation {
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
      passthru.nup = ["--version=branch"];
    };

    packages.millennium-achievement-groups = release rec {
      pname = "achievement-groups";
      version = "2.1.0";
      url = "https://github.com/BossSloth/SteamHunter-plugin/releases/download/v${version}/Achievement-Groups-plugin-${version}.zip";
      hash = "sha256-Lu7ORsn9uRRb83FkbBOxH137ulJyohgwmqqvzJlqAx8=";
      passthru.nup = [];
    };

    packages.millennium-extendium = release rec {
      pname = "extendium";
      version = "2.0.4";
      url = "https://github.com/BossSloth/Extendium/releases/download/v${version}/extendium-${version}.zip";
      hash = "sha256-ecchVQE6Syk+WJt+jMs1ZHk254Z/Gl2JArajsnyB26Q=";
      passthru.nup = [];
    };

    packages.millennium-global-launch-options = release rec {
      pname = "global-launch-options";
      version = "1.1.0";
      url = "https://github.com/BlafKing/steam-global-launch-options/releases/download/v${version}/steam-global-launch-options.zip";
      hash = "sha256-0OnTDvHeT5f1an0gil3mbgneV7PHULyMj/UgBhmhoZk=";
      passthru.nup = [];
    };

    packages.millennium-hltb = release rec {
      pname = "hltb-for-millennium";
      version = "2.2.0";
      url = "https://github.com/jcdoll/hltb-millennium-plugin/releases/download/v${version}/hltb-for-millennium-${version}.zip";
      hash = "sha256-LH9JzLHSIOgJcasPEsFwQkninysyyzty37xDnFv0m/g=";
      passthru.nup = [];
    };

    packages.millennium-protondb-library-badges = release rec {
      pname = "protondb-library-badges";
      version = "1.0.1";
      url = "https://github.com/Yohlo/protondb-library-badges/releases/download/v${version}/protondb-library-badges-v${version}.zip";
      hash = "sha256-TvHxDWimhL+/4vjHLeNLTy+1kfrQiK1nEKgaayV7JQo=";
      passthru.nup = [];
    };

    packages.millennium-size-on-disk = release rec {
      pname = "size-on-disk";
      version = "1.2.0";
      url = "https://github.com/k0d13/steam-size-on-disk/releases/download/v${version}/size-on-disk-${version}.zip";
      hash = "sha256-uEoNS5rYUblax0+eCG8B6zHt3XIoDdQFqzt3PxhamCc=";
      stripRoot = false;
      passthru.nup = [];
    };

    # no releases; the dev build of the commit the plugin store pins
    packages.millennium-steam-easygrid = release {
      pname = "steam-easygrid";
      version = "0-unstable-2026-08-23";
      url = "https://github.com/luthor112/steam-easygrid/releases/download/dev-3be3c47ec244d722393be79a6868c35688672c22/steam-easygrid.zip";
      hash = "sha256-SyPQhmNKYp0jEEMdEID5pfFuO0kQZtrWnF1Zvf/Hnfg=";
      stripRoot = false;
    };

    packages.adwaita-for-steam = pkgs.srcOnly rec {
      stdenv = pkgs.stdenvNoCC;
      pname = "adwaita-for-steam";
      version = "4.4";
      src = pkgs.fetchFromGitHub {
        owner = "tkashkin";
        repo = "Adwaita-for-Steam";
        rev = version;
        hash = "sha256-wH0z2LZ94j5ErRI40f9IRBJXJ6yuL+NLgjmj9G8odxU=";
      };
      passthru.nup = [];
    };
  };
}

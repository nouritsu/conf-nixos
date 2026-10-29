{
  perSystem = {pkgs, ...}: let
    release = {
      url,
      hash,
      ...
    } @ args:
      pkgs.srcOnly (removeAttrs args ["url" "hash"]
        // {
          stdenv = pkgs.stdenvNoCC;
          src = pkgs.fetchzip {inherit url hash;};
        });

    # plugin packer, prebuilt in the npm package
    starlight = pkgs.stdenv.mkDerivation rec {
      pname = "starlight";
      version = "1.1.6";
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@steambrew/starlight/-/starlight-${version}.tgz";
        hash = "sha256-55wg5EKbDLZkoBPZ7x3SyHS7tdiN6JaVuLh9OPQKMy0=";
      };
      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.stdenv.cc.cc.lib];
      installPhase = "install -Dm755 binaries/starlight-linux-x64 $out/bin/starlight";
      passthru.nup = [];
    };
  in {
    packages.starlight = starlight;

    # not in the plugin store; its only release is a rolling `latest` asset
    packages.millennium-steam-native-notifications = pkgs.stdenvNoCC.mkDerivation {
      pname = "steam-native-notifications";
      version = "latest-unstable-2026-10-27";
      src = pkgs.fetchFromGitHub {
        owner = "tyvsmith";
        repo = "steam-native-notifications";
        rev = "3dac4312b0df9c8e2fcb8ad083f8bda409d9a68f";
        hash = "sha256-5MP9dwlVUXg3Hw6Gbv2Q8GCYWWgIWOnZJOIR5SbuFOM=";
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
      version = "2.1.1";
      url = "https://github.com/BossSloth/SteamHunter-plugin/releases/download/v${version}/Achievement-Groups-plugin-${version}.zip";
      hash = "sha256-TuX8tnR/lxhJ+UObctObHndtztMPWhkytfIKbAisn6g=";
      passthru.nup = [];
    };

    packages.millennium-extendium = release rec {
      pname = "extendium";
      version = "2.0.5";
      url = "https://github.com/BossSloth/Extendium/releases/download/v${version}/extendium-${version}.zip";
      hash = "sha256-xLgXWSU06onhi5JACcxbTh3qrgVqtkNRco1dbvcWLtk=";
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

    # releases are a single .star since 1.3.0
    packages.millennium-size-on-disk = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "size-on-disk";
      version = "1.3.1";
      src = pkgs.fetchurl {
        url = "https://github.com/k0d13/steam-size-on-disk/releases/download/v${version}/size-on-disk-${version}.star";
        hash = "sha256-VJohLQSYLCj71zBlTM5yqS8iuER2lCYDPdkfj2YtTAo=";
      };
      dontUnpack = true;
      installPhase = "cp $src $out";
      dontFixup = true;
      passthru.nup = [];
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

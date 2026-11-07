{
  nixpkgs' = {
    unfree = ["stm32cubemx" "nrfconnect" "nrf-udev" "segger-jlink"];
    # J-Link GUI tools bundle EOL Qt4
    insecure = ["segger-jlink-qt4"];
    config.segger-jlink.acceptLicense = true;
  };

  den.aspects.dev = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.jq
        pkgs.grex
        pkgs.tokei
      ];

      programs.fish.shellAliases.count-code = "tokei";
    };

    provides = {
      direnv.nixos = {
        programs.direnv = {
          enable = true;
          silent = true;
        };

        programs.fish.shellAbbrs.direnv-init = "printf '%s\\n' 'eval \"$(devenv direnvrc)\"' 'use devenv' > .envrc && direnv allow";
        programs.fish.interactiveShellInit = ''
          abbr -a flake-init --set-cursor 'nix flake init -t $NH_FLAKE#%'
        '';
      };

      devenv.nixos = {pkgs, ...}: {
        environment.systemPackages = [pkgs.devenv];

        nix.settings.extra-substituters = ["https://devenv.cachix.org"];
        nix.settings.trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];

        programs.fish.shellAbbrs = {
          ds = "devenv shell";
          dvup = "devenv up";
          dvt = "devenv tasks run";
          dvu = "devenv update";
          dvs = "devenv search";
        };
      };

      android.nixos = {
        self',
        pkgs,
        lib,
        ...
      }: {
        environment.systemPackages = [
          pkgs.android-tools
          self'.packages.scrcpy
        ];

        which-key'.menu.t.submenu.p = {
          desc = "scrcpy";
          icon = "f0121";
          cmd = lib.getExe self'.packages.scrcpy;
          app-id = "scrcpy";
        };

        programs.fish.shellAbbrs = {
          ads = "adb shell";
          adi = "adb install";
          adp = "adb push";
          adc = "adb connect";
        };
      };

      embedded = {
        nixos = {pkgs, ...}: {
          environment.variables._JAVA_AWT_WM_NONREPARENTING = "1";

          environment.systemPackages = [
            pkgs.openocd
            pkgs.eclipses.eclipse-embedcpp
            pkgs.stm32cubemx
            pkgs.nrfconnect # power profiler app for the PPK2 lives in here
            pkgs.segger-jlink # nRF Connect refuses to flash without a system J-Link
          ];

          services.udev.packages = [
            pkgs.stlink
            pkgs.nrf-udev
            pkgs.segger-jlink
            pkgs.platformio-core.udev
          ];
        };
      };

      nix.nixos = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.nixd
          pkgs.nil
          pkgs.alejandra
          pkgs.statix
          pkgs.nix-inspect
          pkgs.manix
          pkgs.nix-output-monitor
          pkgs.nix-tree
          pkgs.nix-diff
          pkgs.nurl
          pkgs.nix-update
          pkgs.nixpkgs-review
          pkgs.nix-search-tv
        ];

        programs.fish.shellAliases = {
          repl-nix = "nix repl";
          ns = "tv nix";
          closure = "nix-tree /run/current-system";
        };
      };
    };
  };
}

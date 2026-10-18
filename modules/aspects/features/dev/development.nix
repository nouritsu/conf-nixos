{den, ...}: {
  den.aspects.dev = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.jq
        pkgs.gnumake
        pkgs.grex
        pkgs.lazydocker
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

        programs.fish.shellAbbrs.direnv-init = "echo 'use flake' > .envrc && direnv allow";
        programs.fish.interactiveShellInit = ''
          abbr -a flake-init --set-cursor 'nix flake init -t $NH_FLAKE#%'
        '';
      };

      android.nixos = {
        self',
        pkgs,
        ...
      }: {
        environment.systemPackages = [
          pkgs.android-tools
          pkgs.slint-viewer
          pkgs.pixelflasher
          self'.packages.scrcpy
        ];
      };

      embedded = {
        includes = [
          (den.batteries.unfree ["stm32cubemx" "nrfconnect" "nrf-udev" "segger-jlink"])

          # J-Link GUI tools bundle EOL Qt4
          (den.batteries.insecure ["segger-jlink-qt4-952"])
        ];
        nixos = {pkgs, ...}: {
          nixpkgs.config.segger-jlink.acceptLicense = true;

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
        ];

        programs.fish.shellAliases.repl-nix = "nix repl";
      };

      python.nixos = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.python3
        ];

        programs.fish.shellAliases.repl-py = "python3";
      };
    };
  };
}

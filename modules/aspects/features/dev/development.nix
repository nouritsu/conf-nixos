{den, ...}: {
  den.aspects.dev = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.bash
        pkgs.jq
        pkgs.gnumake
        pkgs.grex
        pkgs.lazydocker
        pkgs.lazygit
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

        programs.fish.shellAbbrs."direnv-init" = "echo 'use flake' > .envrc && direnv allow";
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

      c.nixos = {
        pkgs,
        lib,
        ...
      }: {
        environment.systemPackages = [
          pkgs.gcc
          pkgs.lldb
          pkgs.clang-tools # clangd, used by Zed and other editors
          (pkgs.writeShellScriptBin "cling" ''
            exec ${lib.getExe pkgs.cling} -Wno-unknown-attributes "$@"
          '')
        ];

        programs.fish.shellAliases.repl-c = "cling";
      };

      embedded = {
        includes = [(den.batteries.unfree ["stm32cubemx" "nrfconnect" "nrf-udev" "segger-jlink"])];
        nixos = {pkgs, ...}: {
          nixpkgs.config.segger-jlink.acceptLicense = true;
          # J-Link GUI tools (JFlash etc.) link against SEGGER's bundled EOL Qt4;
          # only those tools use it, so scope the exception to this aspect
          nixpkgs.config.permittedInsecurePackages = ["segger-jlink-qt4-952"];

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
          pkgs.black
          pkgs.ruff
        ];

        programs.fish.shellAliases.repl-py = "python3";
      };

      rust.nixos = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.rustup
          pkgs.bacon
          pkgs.evcxr
        ];

        programs.fish.shellAliases.repl-rs = "evcxr";

        programs.fish.interactiveShellInit = ''
          fish_add_path ~/.cargo/bin
        '';
      };
    };
  };
}

{
  flake.nixosModules = {
    dev-core = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        bash
        jq
        gnumake
        grex
        lazydocker
        lazygit
        tokei
      ];

      programs.fish.shellAliases = {
        count-code = "tokei";
      };
    };

    dev-direnv = {...}: {
      programs.direnv = {
        enable = true;
        silent = true;
      };

      programs.fish.shellAbbrs = {
        "direnv-init" = "echo 'use flake' > .envrc && direnv allow";
      };
    };

    dev-android = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.android-tools
        pkgs.slint-viewer
      ];
    };

    dev-c = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = [
        pkgs.gcc
        pkgs.lldb
        (pkgs.writeShellScriptBin "cling" ''
          exec ${lib.getExe pkgs.cling} -Wno-unknown-attributes "$@"
        '')
      ];

      programs.fish.shellAliases.repl-c = "cling";
    };

    dev-nix = {pkgs, ...}: {
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

    dev-python = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.python3
        pkgs.black
        pkgs.ruff
      ];

      programs.fish.shellAliases.repl-py = "python3";
    };

    dev-rust = {pkgs, ...}: {
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
}

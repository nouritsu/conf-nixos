{den, ...}: {
  den.default = {
    includes = [
      den.batteries.hostname
      den.batteries.define-user

      # Hand every class module the system-selected flake outputs, so aspects
      # can say self'.packages.foo instead of threading `self` through the
      # flake-parts scope and indexing it by pkgs.stdenv.hostPlatform.system.
      den.batteries.self'
      den.batteries.inputs'
    ];

    # Zed editor — tuned for embedded C/C++ with Nix and other common
    # languages. Catppuccin Mocha comes from the catppuccin-nix module
    # (see features/theme/catppuccin.nix); the stylix Zed target is
    # disabled in features/theme/stylix.nix so it does not override it.
    homeManager.programs.zed-editor = {
      enable = true;

      extensions = [
        "nix"
        "toml"
        "cmake"
        "make"
        "dockerfile"
        "html"
        "doxygen"
      ];

      userSettings = {
        # ZedMono Nerd Font to match the rest of the system (stylix).
        buffer_font_family = "ZedMono Nerd Font";
        ui_font_family = "ZedMono Nerd Font";
        buffer_font_size = 15;
        ui_font_size = 15;

        # Theme is set by the catppuccin module; keep the OS following it.
        theme.mode = "system";

        vim_mode = false;
        format_on_save = "on";
        tab_size = 4;
        ensure_final_newline_on_save = true;

        terminal.font_family = "ZedMono Nerd Font";

        # Embedded/C toolchain: clangd ships with Zed and picks up
        # compile_commands.json / .clangd for cross targets.
        lsp = {
          clangd.binary.path_lookup = true;
          nil.binary.path_lookup = true;
          nixd.binary.path_lookup = true;
        };

        languages = {
          Nix = {
            language_servers = ["nil" "!nixd"];
            formatter.external = {
              command = "alejandra";
              arguments = ["-q" "-"];
            };
          };
          C = {
            format_on_save = "on";
            tab_size = 4;
          };
          "C++" = {
            format_on_save = "on";
            tab_size = 4;
          };
        };
      };
    };

    # ================================================================ #
    # =                         DO NOT TOUCH                         = #
    # ================================================================ #
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
  };
}

{
  den.aspects.dev.provides.godot = {
    nixos = {
      self',
      pkgs,
      lib,
      config,
      ...
    }: let
      godot = self'.packages.godot;
      templates = godot.configuration.package.export-templates-bin;
      # the directory Godot looks for: 4.7.2-stable -> 4.7.2.stable
      version = lib.replaceStrings ["-"] ["."] godot.configuration.package.version;
    in {
      environment.systemPackages =
        [
          godot
          self'.packages.godot-lsp
          pkgs.gdscript-formatter
          pkgs.ldtk
          pkgs.tiled
          pkgs.sfxr-qt
          pkgs.audacity
        ]
        # Aseprite and Blender are the Steam installs, launched through
        # steam-run, so only hosts with Steam get the launchers; Godot's
        # settings pick them up from there (packages/godot/godot.nix).
        ++ lib.optionals config.programs.steam.enable [
          self'.packages.aseprite-steam
          self'.packages.blender-steam
        ];

      # Godot reads export templates only from its data dir, one directory per
      # version, so they can't come from the system profile. Re-linked on every
      # switch and login.
      systemd.user.tmpfiles.rules = [
        "L+ %h/.local/share/godot/export_templates/${version} - - - - ${templates}/share/godot/export_templates/${version}"
      ];
    };

    homeManager = {
      self',
      lib,
      ...
    }: {
      # The extension would run `nc 127.0.0.1 6005` against an open editor;
      # the bridge also covers a closed one.
      programs.zed-editor = {
        extensions = ["gdscript"];
        userSettings.lsp.gdscript.binary = {
          path = lib.getExe self'.packages.godot-lsp;
          arguments = [];
        };
      };
    };
  };
}

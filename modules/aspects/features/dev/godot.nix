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
        # Steam installs, so only on hosts with Steam
        ++ lib.optionals config.programs.steam.enable [
          self'.packages.aseprite-steam
          self'.packages.blender-steam
        ];

      # Godot only reads export templates from its data dir
      systemd.user.tmpfiles.rules = [
        "L+ %h/.local/share/godot/export_templates/${version} - - - - ${templates}/share/godot/export_templates/${version}"
      ];
    };

    homeManager = {
      self',
      lib,
      ...
    }: {
      # the bridge also works with no editor open
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

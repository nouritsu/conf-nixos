{
  den.aspects.dev.provides.godot = {
    nixos = {
      self',
      pkgs,
      lib,
      config,
      ...
    }: {
      environment.systemPackages =
        [
          self'.packages.godot
          self'.packages.godot-lsp
          pkgs.gdscript-formatter
        ]
        # Steam installs, so only on hosts with Steam
        ++ lib.optionals config.programs.steam.enable [
          self'.packages.aseprite-steam
          self'.packages.blender-steam
        ];
    };
  };
}

{self, ...}: {
  flake.nixosModules.opts-hm-modules = {
    lib,
    config,
    ...
  }: {
    options = let
      inherit (lib) mkOption types;
    in {
      my.hmUsers = mkOption {
        type = types.listOf types.str;
      };

      my.hmModules = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
    config = {
      home-manager.users = lib.genAttrs config.my.hmUsers (_: {
        imports = map (name: self.homeModules.${name}) (lib.unique config.my.hmModules);
      });
    };
  };
}

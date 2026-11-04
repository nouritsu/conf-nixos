let
  # in the order isup lists them
  groups = ["Online" "Homelab" "Nix caches"];
in {
  # on every host, so any aspect can add checks
  den.default.nixos = {lib, ...}: let
    inherit (lib) mkOption types;
    maybe = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  in {
    options.isup'.checks = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
          };
          group = mkOption {
            type = types.enum groups;
            default = "Online";
          };
          # statuspage.io base url
          status = maybe;
          # components or component groups that count; empty is the whole page
          components = mkOption {
            type = types.listOf types.str;
            default = [];
          };
          # down on no answer or a 5xx
          url = maybe;
          # a resolver, asked directly
          dns = maybe;
        };
      }));
      default = {};
    };
  };

  den.aspects.isup.nixos = {
    config,
    self',
    pkgs,
    lib,
    ...
  }: let
    rank = check: lib.lists.findFirstIndex (g: g == check.group) 0 groups;
    checks = lib.sort (a: b:
      if rank a != rank b
      then rank a < rank b
      else lib.toLower a.name < lib.toLower b.name)
    (lib.mapAttrsToList (id: check: check // {inherit id;}) config.isup'.checks);

    isup = pkgs.symlinkJoin {
      name = "isup";
      paths = [self'.packages.isup];
      nativeBuildInputs = [pkgs.makeBinaryWrapper];
      postBuild = ''
        rm $out/bin/isup
        makeWrapper ${lib.getExe self'.packages.isup} $out/bin/isup \
          --add-flag --checks --add-flag ${pkgs.writeText "isup-checks.json" (builtins.toJSON checks)}
      '';
      meta.mainProgram = "isup";
    };
  in {
    environment.systemPackages = [isup];
    programs.fish.shellAbbrs.isuph = "isup homelab";
  };
}

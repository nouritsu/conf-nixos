{
  flake.nixosModules.opts-submaps = {...}: {
    /*
    my.submaps."Meta+G".binds = [
      {
        key = ""
        title = ""
        cmd = ""
      }

      {
        key = ""
        title = ""
        cmd = ""
      }
    ];

    # set by our configuration -
    my.submaps."Meta+G".conf = "/nix/store/.../config-meta+g.yaml"

    # path obtained by writing
    {
      description = "A very cool Nix flake";

      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      };

      outputs = { self, nixpkgs, ... }:
        let
          pkgs = nixpkgs.legacyPackages."x86_64-linux";

          mkMenu = menu: let
            configFile = pkgs.writeText "config.yaml"
              (pkgs.lib.generators.toYAML {} {
                anchor = "bottom-right";
                # ...
                inherit menu;
              });
          in
            pkgs.writeShellScriptBin "my-menu" ''
              exec ${pkgs.lib.getExe pkgs.wlr-which-key} ${configFile}
            '';
        in {
          packages.x86_64-linux.default = mkMenu [
            {
              key = "f";
              desc = "Firefox";
              cmd = "firefox";
            }
          ];
        };
    }
    */
  };
}

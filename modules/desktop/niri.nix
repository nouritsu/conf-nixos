{self, ...}: {
  flake.nixosModules.desktop-niri = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    wniri = self.packages.${system}.niri;
  in {
    programs.niri = {
      enable = true;
      package = wniri;
    };

    environment.systemPackages = [pkgs.xwayland-satellite];

    # TODO: fix
    # restart niri with new settings on rebuild
    system.userActivationScripts = {
      niri-reload-config = {
        text = lib.getExe (
          pkgs.writeShellApplication {
            name = "niri-reload-config";
            runtimeInputs = [
              config.programs.niri.package
              pkgs.procps
            ];
            text = ''
              if pgrep -x "niri" > /dev/null; then
                if [[ -z "''${NIRI_SOCKET:-}" ]]; then
                  runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
                  for sock in "$runtime_dir"/niri.*.sock; do
                    if [[ -S "$sock" ]]; then
                      export NIRI_SOCKET="$sock"
                      break
                    fi
                  done
                fi
                if [[ -n "''${NIRI_SOCKET:-}" ]]; then
                  niri msg action load-config-file --path "${config.programs.niri.package.passthru.configPath}"
                fi
              fi
            '';
          }
        );
      };
    };
  };
}

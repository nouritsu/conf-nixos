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
                niri msg action load-config-file --path "${wniri}/niri-config.kdl"
              fi
            '';
          }
        );
      };
    };
  };
}

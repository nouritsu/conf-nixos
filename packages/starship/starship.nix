{
  self,
  inputs,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
    packages.starship = wrappers.wrappers.starship.wrap [
      {
        inherit pkgs;
        package = pkgs.starship;
      }

      self.nixosModules.wstarship-settings
      self.nixosModules.wstarship-theme

      # host stats, time and battery, picked by fish over ssh
      ({
        config,
        lib,
        ...
      }: {
        # default only, so the STARSHIP_CONFIG fish exports wins
        env.STARSHIP_CONFIG = lib.mkForce null;
        envDefault.STARSHIP_CONFIG = config.constructFiles."starship.toml".path;

        constructFiles."starship-ssh.toml" = {
          relPath = "starship-ssh.toml";
          content = builtins.toJSON (lib.recursiveUpdate config.settings {
            custom.cpu.disabled = false;
            memory_usage.disabled = false;
            custom.load.disabled = false;
            time.disabled = false;
            battery.disabled = false;
          });
          builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
        };
      })
    ];
  };
}

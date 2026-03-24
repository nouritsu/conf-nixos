{self, ...}: {
  flake.nixosModules = {
    ai-opencode = {pkgs, ...}: {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.opencode
      ];

      programs.fish.shellAbbrs = {
        oc = "opencode";
      };
    };
  };
}

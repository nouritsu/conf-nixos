{self, ...}: {
  flake.nixosModules = {
    ai-opencode = {pkgs, ...}: {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.opencode
        self.packages.${pkgs.stdenv.hostPlatform.system}.spotify
        pkgs.claude-code
      ];

      programs.fish.shellAbbrs = {
        oc = "opencode";
      };
    };
  };
}

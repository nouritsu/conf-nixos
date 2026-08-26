{
  self,
  den,
  ...
}: {
  den.aspects.ai = {
    includes = [(den.batteries.unfree ["claude-code" "cursor"])];
    nixos = {pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) system;
    in {
      environment.systemPackages = [
        self.packages.${system}.opencode
        pkgs.claude-code
        pkgs.code-cursor
      ];

      programs.fish.shellAbbrs.oc = "opencode";
    };
  };
}

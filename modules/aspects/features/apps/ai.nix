{den, ...}: {
  den.aspects.ai = {
    includes = [(den.batteries.unfree ["claude-code" "cursor"])];
    nixos = {
      self',
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        self'.packages.opencode
        pkgs.claude-code
        pkgs.code-cursor
      ];

      programs.fish.shellAbbrs.oc = "opencode";
    };
  };
}

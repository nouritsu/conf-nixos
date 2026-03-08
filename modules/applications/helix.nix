{
  inputs,
  self,
  ...
}: {
  perSystem = {system, ...}: {
    packages.helix = inputs.helix.packages.${system}.helix-full;
    packages.helix-min = inputs.helix.packages.${system}.helix-min;
  };

  flake.nixosModules = {
    app-helix = {pkgs, ...}: {
      environment.systemPackages = [
        self.packages.${pkgs.system}.helix
      ];

      nix.settings = {
        extra-substituters = ["https://helix.cachix.org"];
        trusted-public-keys = ["helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="];
      };

      programs.nano.enable = false;

      environment.variables = {
        EDITOR = "hx";
      };

      programs.fish.shellAliases = let
        e = "hx";
      in {
        helix = e;
        vi = e;
        vim = e;
        nvim = e;
      };
    };
  };
}

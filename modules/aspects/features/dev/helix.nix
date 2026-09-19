{
  den.aspects.helix.nixos = {self', ...}: {
    environment.systemPackages = [
      self'.packages.helix
    ];

    nix.settings = {
      extra-substituters = ["https://helix.cachix.org"];
      trusted-public-keys = ["helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="];
    };

    programs.nano.enable = false;

    environment.variables.EDITOR = "hx";

    programs.fish.shellAliases = let
      e = "hx";
    in {
      helix = e;
      vi = e;
      vim = e;
      nvim = e;
    };
  };
}

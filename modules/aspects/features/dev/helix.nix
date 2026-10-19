{
  den.aspects.helix.nixos = {
    self',
    lib,
    ...
  }: {
    environment.systemPackages = [
      self'.packages.helix
    ];

    xdg.mime.defaultApplications = lib.genAttrs [
      "text/plain"
      "text/markdown"
      "text/x-csrc"
      "text/x-c++src"
      "text/x-python"
      "text/x-shellscript"
      "application/json"
      "application/xml"
      "application/toml"
      "application/yaml"
      "application/x-zerosize"
    ] (_: "Helix.desktop");

    nix.settings = {
      extra-substituters = ["https://helix.cachix.org"];
      trusted-public-keys = ["helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="];
    };

    programs.nano.enable = false;

    environment.variables.EDITOR = "hx";

    # open every file rg matches
    programs.fish.interactiveShellInit = ''
      function hxrg
        hx (rg -l $argv)
      end
    '';

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

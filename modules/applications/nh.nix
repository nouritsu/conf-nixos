{
  flake.nixosModules = {
    app-nh = {...}: {
      programs.nh = {
        enable = true;
        flake = "/home/aneesh/.config/nixos";

        clean.enable = true;
        clean.extraArgs = "--keep 5 --keep-since 7d";
      };

      programs.fish.shellAliases = {
        conf = "$EDITOR $NH_FLAKE";
      };

      programs.fish.shellAbbrs = {
        nhrb = "nh os boot";
        nhrs = "nh os switch";
        nhrt = "nh os test";
        nhca = "nh clean all";
        nhs = "nh search";
      };
    };
  };
}

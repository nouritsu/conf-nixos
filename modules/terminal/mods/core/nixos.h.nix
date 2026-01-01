{pkgs, ...}: {
  home.packages = [
    pkgs.nh
  ];

  home.shellAliases = {
    conf = "$EDITOR $NH_FLAKE";
  };

  programs.fish.shellAbbrs = {
    nhrb = "nh os boot";
    nhrs = "nh os switch";
    nhrt = "nh os test";
    nhps = "nh search";
  };
}

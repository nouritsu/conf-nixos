{
  nix.optimise = {
    automatic = true;
    dates = ["*-*-1/3 21:00"]; # every third day at 21:00
  };

  programs.nh.enable = true; # in case I remove nh from my programs
  programs.nh.clean = {
    enable = true;
    extraArgs = "--keep 5 --keep-since 7d";
  };
}

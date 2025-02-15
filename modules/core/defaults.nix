{pkgs, ...}: {
  # Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}

# One `nix run .#<host>` per declared host, wrapping `nh os <action>` against
# that host's nixosConfiguration. Switching the laptop from the desktop (or the
# other way round) then needs no hand-written --flake path.
{den, ...}: {
  perSystem = {pkgs, ...}: {
    packages = den.lib.nh.denPackages {fromFlake = true;} pkgs;
  };
}

# treefmt pre-commit hook; nix fmt still goes through the flake
{pkgs, ...}: {
  imports = [./templates/base/devenv.nix];

  # one-off tools, kept off the system
  packages = [
    pkgs.sbctl
    pkgs.ssh-audit
    pkgs.protonup-ng
  ];

  # t starship [args]: run a packages/ wrapper from the working tree
  scripts.t.exec = ''
    pkg=$1
    shift
    exec nix run "$DEVENV_ROOT#$pkg" -- "$@"
  '';

  # packages/ one-offs, built from the working tree on each run
  scripts.balatro-sync.exec = ''exec nix run "$DEVENV_ROOT#balatro-sync" -- "$@"'';
  scripts.nup.exec = ''exec nix run "$DEVENV_ROOT#nup" -- "$@"'';
}

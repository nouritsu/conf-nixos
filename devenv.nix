# treefmt pre-commit hook; nix fmt still goes through the flake
{
  imports = [./templates/base/devenv.nix];

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

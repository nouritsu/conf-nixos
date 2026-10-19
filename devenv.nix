# treefmt pre-commit hook; nix fmt still goes through the flake
{
  imports = [./templates/base/devenv.nix];
}

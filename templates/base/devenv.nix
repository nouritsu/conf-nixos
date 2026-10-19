# imported by every template; needs the git-hooks and treefmt-nix inputs
{
  config,
  lib,
  ...
}: {
  treefmt = {
    enable = true;
    config.imports = [./treefmt.nix];
  };

  # format at commit, not over the whole tree on every shell entry
  tasks."devenv:treefmt:run".before = lib.mkForce [];

  git-hooks.hooks.treefmt.enable = true;

  # only the cli loads .env; flake-mode shells assert against it
  dotenv.enable = !config.devenv.flakesIntegration;

  # .claude/settings.json, runs the git hooks after claude edits
  claude.code.enable = true;
}

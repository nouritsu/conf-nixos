{pkgs, ...}: {
  languages.python = {
    enable = true;
    # helix brings basedpyright
    lsp.enable = false;
    # for wheels uv installs
    manylinux.enable = true;
    venv.enable = true;
    # uv sync runs as a task whenever pyproject.toml changes
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  packages = [pkgs.ruff];

  treefmt.config.programs.ruff-format.enable = true;

  git-hooks.hooks.ruff.enable = true;

  scripts.lint.exec = ''ruff check "$@"'';

  enterTest = "uv run pytest";
}

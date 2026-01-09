{pkgs, ...}: let
  basedpyright = "${pkgs.basedpyright}/bin/basedpyright-langserver";
  ruff = "${pkgs.ruff}/bin/ruff";
in {
  programs.helix.languages = {
    language-server = {
      basedpyright = {
        command = basedpyright;
        args = ["--stdio"];
        config = {};
      };
      ruff = {
        command = ruff;
        args = ["server"];
      };
    };

    language = [
      {
        name = "python";
        scope = "source.python";
        injection-regex = "py(thon)?";
        file-types = [
          "py"
          "pyi"
          "py3"
          "pyw"
          "ptl"
          "rpy"
          "cpy"
          "ipy"
          "pyt"
          {glob = ".python_history";}
          {glob = ".pythonstartup";}
          {glob = ".pythonrc";}
          {glob = "*SConstruct";}
          {glob = "*SConscript";}
          {glob = "*sconstruct";}
        ];
        shebangs = ["python" "uv"];
        roots = ["pyproject.toml" "setup.py" "poetry.lock" "pyrightconfig.json"];
        comment-token = "#";
        language-servers = [
          "basedpyright"
          {
            name = "ruff";
            except-features = ["format"];
          }
        ];
        formatter = {
          command = ruff;
          args = ["format" "-"];
        };
        indent = {
          tab-width = 4;
          unit = "    ";
        };
        auto-format = true;
      }
    ];
  };
}

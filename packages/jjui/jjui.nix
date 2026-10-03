{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  inherit (nix-colors.colorSchemes.catppuccin-mocha) palette;

  c = slot: "#${palette.${slot}}";
  base = c "base00";
  surface0 = c "base02";
  surface1 = c "base03";
  overlay = c "base04";
  text = c "base05";
  red = c "base08";
  peach = c "base09";
  yellow = c "base0A";
  green = c "base0B";
  teal = c "base0C";
  blue = c "base0D";
  mauve = c "base0E";

  # no catppuccin port; mauve for every highlight
  colors = {
    text = {
      fg = text;
      bg = base;
    };
    dimmed = {
      fg = overlay;
      bg = base;
    };
    selected = {
      fg = text;
      bg = surface0;
      bold = true;
    };
    border.fg = overlay;
    title = {
      fg = mauve;
      bold = true;
    };
    shortcut.fg = mauve;
    matched.fg = yellow;
    error = {
      fg = red;
      bold = true;
    };
    success = {
      fg = green;
      bold = true;
    };

    bookmark.fg = mauve;
    branch.fg = peach;
    change.fg = red;
    commit.fg = green;
    file.fg = yellow;
    workspace.fg = blue;
    rebase.bold = true;
    source_marker = {
      fg = base;
      bg = teal;
      bold = true;
    };
    target_marker = {
      fg = base;
      bg = green;
      bold = true;
    };

    revisions.fg = text;
    "revisions selected".bg = surface0;
    "revisions dimmed".fg = overlay;
    "revisions details selected".bg = surface1;
    "revisions rebase source_marker".bold = true;
    "revisions rebase target_marker".bold = true;

    details.fg = text;
    "details selected".bold = true;
    evolog.fg = text;
    "evolog selected" = {
      fg = text;
      bg = surface1;
      bold = true;
    };
    "oplog selected".bold = true;
    preview.fg = text;
    "preview border".fg = surface0;

    "revset title" = {
      fg = mauve;
      bold = true;
    };
    "revset text" = {
      fg = text;
      bold = true;
    };
    "revset completion text".fg = text;
    "revset completion selected" = {
      fg = text;
      bg = surface1;
    };
    "revset completion matched" = {
      fg = yellow;
      bold = true;
    };
    "revset completion dimmed".fg = overlay;

    completion.fg = text;
    "completion selected".bold = true;

    menu.bg = base;
    "menu border".fg = surface0;
    "menu title" = {
      fg = base;
      bg = mauve;
      bold = true;
    };
    "menu shortcut".fg = mauve;
    "menu selected" = {
      fg = text;
      bg = surface1;
    };
    "menu matched" = {
      fg = yellow;
      bold = true;
    };
    "menu dimmed".fg = overlay;

    help.bg = base;
    "help border".fg = surface0;
    "help title" = {
      fg = mauve;
      bold = true;
      underline = true;
    };

    status.bg = surface0;
    "status title" = {
      fg = base;
      bg = mauve;
      bold = true;
    };
    "status shortcut".fg = mauve;
    "status dimmed".fg = overlay;

    confirmation.bg = base;
    "confirmation border" = {
      fg = red;
      bold = true;
    };
    "confirmation text" = {
      fg = mauve;
      bold = true;
    };
    "confirmation selected" = {
      fg = text;
      bg = surface1;
    };
    "confirmation dimmed".fg = overlay;

    undo.bg = base;
    "undo confirmation selected" = {
      fg = text;
      bg = surface1;
    };
    "undo confirmation dimmed".fg = overlay;
  };
in {
  perSystem = {pkgs, ...}: {
    packages.jjui = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.jjui;
      }
      ({config, ...}: {
        constructFiles.config = {
          relPath = "jjui/config.toml";
          content = builtins.toJSON {ui.colors = colors;};
          builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
        };

        env.JJUI_CONFIG_DIR = dirOf config.constructFiles.config.path;
      })
    ];
  };
}

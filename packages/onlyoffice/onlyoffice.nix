{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: let
    id = "theme-catppuccin-mocha";

    editors = ["document" "spreadsheet" "presentation" "pdf" "visio"];
    perEditor = key: colour: lib.genAttrs (map (editor: "${key}-${editor}") editors) (_: colour);

    # catppuccin colour names, name/alpha for translucent ones, other values as is
    # keys without a value here fall back to the built-in dark theme
    colors =
      perEditor "toolbar-header" "crust"
      // perEditor "text-toolbar-header-on-background" "crust"
      // perEditor "highlight-header-tab-underline" "mauve"
      // perEditor "highlight-toolbar-tab-underline" "mauve"
      // {
        # Header
        text-toolbar-header = "text";
        icon-toolbar-header = "text";
        highlight-header-button-hover = "surface0";
        highlight-header-button-pressed = "surface1";

        # Panels
        background-normal = "base";
        background-toolbar = "mantle";
        background-toolbar-additional = "surface0";
        background-pane-additional = "surface0";
        background-contrast-popover = "surface0";
        background-notification-popover = "surface0";
        background-notification-badge = "yellow";
        background-alt-key-hint = "yellow";
        background-loader = "crust/90";

        # Buttons
        background-primary-dialog-button = "mauve";
        highlight-primary-dialog-button-hover = "mauve/85";
        background-accent-button = "mauve";
        background-fill-button = "yellow";
        highlight-fill-button-hover = "yellow/85";
        highlight-fill-button-pressed = "yellow/70";
        highlight-button-hover = "surface0";
        highlight-button-pressed = "surface1";
        highlight-button-pressed-hover = "surface2";
        highlight-comment-hover = "surface0";
        highlight-comment-pressed = "surface1";
        highlight-text-select = "mauve";

        # Borders
        border-toolbar = "surface0";
        border-divider = "surface0";
        border-regular-control = "surface1";
        border-contrast-popover = "surface1";
        border-control-focus = "mauve";
        border-button-pressed-focus = "mauve";
        border-preview-hover = "mauve/60";
        border-preview-select = "mauve";

        # Text
        text-normal = "text";
        text-normal-pressed = "text";
        text-secondary = "subtext1";
        text-tertiary = "subtext0";
        text-link = "mauve";
        text-link-hover = "mauve";
        text-link-active = "mauve";
        text-link-visited = "mauve";
        text-inverse = "crust";
        text-alt-key-hint = "crust";

        # Icons
        icon-normal = "text";
        icon-normal-pressed = "text";
        icon-success = "green";

        # Canvas, page stays white
        canvas-background = "base";
        canvas-page-border = "surface1";
        canvas-ruler-background = "base";
        canvas-ruler-border = "surface1";
        canvas-ruler-margins-background = "mantle";
        canvas-ruler-mark = "subtext0";
        canvas-ruler-handle-border = "subtext0";
        canvas-ruler-handle-border-disabled = "overlay0";
        canvas-select-all-icon = "overlay1";

        # Spreadsheet headings
        canvas-cell-title-text = "subtext1";
        canvas-cell-title-background = "mantle";
        canvas-cell-title-background-hover = "surface0";
        canvas-cell-title-background-selected = "surface1";
        canvas-cell-title-border = "surface0";
        canvas-cell-title-border-hover = "surface1";
        canvas-cell-title-border-selected = "surface2";

        # Scrollbars
        canvas-scroll-thumb = "surface0";
        canvas-scroll-thumb-hover = "surface1";
        canvas-scroll-thumb-pressed = "surface2";
        canvas-scroll-thumb-border = "surface1";
        canvas-scroll-thumb-border-hover = "surface2";
        canvas-scroll-thumb-border-pressed = "overlay0";
        canvas-scroll-thumb-target = "overlay1";
        canvas-scroll-thumb-target-hover = "overlay2";
        canvas-scroll-thumb-target-pressed = "overlay2";
        canvas-scroll-arrow = "overlay1";
        canvas-scroll-arrow-hover = "overlay2";
        canvas-scroll-arrow-pressed = "overlay2";

        # Animation pane
        canvas-anim-pane-background = "mantle";
        canvas-anim-pane-item-fill-selected = "surface1";
        canvas-anim-pane-item-fill-hovered = "surface0";
        canvas-anim-pane-button-fill = "surface0";
        canvas-anim-pane-button-fill-hovered = "surface1";
        canvas-anim-pane-timeline-ruler-outline = "surface1";
        canvas-anim-pane-timeline-ruler-tick = "surface0";
        canvas-anim-pane-timeline-scroller-fill = "surface1";

        # Window, read by Qt so no alpha
        window-border = "surface0";
        menu-background = "base";
        menu-border = "surface1";
        menu-item-hover-background = "surface0";
        menu-text = "text";
        menu-text-item-hover = "text";
        menu-text-item-disabled = "overlay0";
        menu-separator = "surface0";
        tooltip-text = "text";
        tooltip-border = "surface1";
        tooltip-background = "base";
        tab-simple-active-background = "crust";
        tab-simple-active-text = "text";
        tab-default-active-background = "base";
        tab-default-active-text = "text";
        tab-divider = "surface0";

        # Downloads
        download-widget-background = "base";
        download-widget-border = "surface1";
        download-item-hover-background = "surface0";
        download-ghost-button-text = "mauve";
        download-ghost-button-text-hover = "text";
        download-ghost-button-text-pressed = "overlay1";
        download-ghost-button-text-pressed-item-hover = "overlay2";
        download-label-text = "text";
        download-label-text-info = "overlay1";
        download-label-text-info-item-hover = "overlay2";
        download-progressbar-chunk = "mauve";
        download-progressbar-background = "surface1";
        download-progressbar-background-item-hover = "surface2";
        download-scrollbar-handle = "overlay1";

        # Start page, its dark values only exist for the built-in themes
        background-action-panel = "base";
        background-normal-element = "mantle";
        background-normal-element-light = "mantle";
        background-tabbar = "mantle";
        background-icon-normal = "surface0";
        background-primary-button = "mauve";
        background-scroll-thumb = "surface1";
        highlight-primary-button-hover = "mauve/85";
        highlight-primary-button-pressed = "mauve/70";
        highlight-accent-button-hover = "mauve/85";
        highlight-accent-button-pressed = "mauve/70";
        highlight-scroll-thumb-hover = "surface2";
        highlight-scroll-track-hover = "text/3";
        highlight-sidebar-item-pressed = "surface0";
        border-tabbar = "surface0";
        border-sidebar = "surface0";
        border-sidebar-icon = "surface1";
        text-negative = "red";
        disabled-element-opacity = ".3";
        theme-inverted-image-filter = "invert(1)";
      };

    named = pkgs.writeText "${id}.json" (builtins.toJSON {
      inherit id colors;
      name = "Catppuccin Mocha";
      type = "dark";
    });

    theme = pkgs.runCommand "onlyoffice-${id}.json" {nativeBuildInputs = [pkgs.jq];} ''
      jq --slurpfile palette ${inputs'.catppuccin.packages.palette}/palette.json '
        $palette[0].mocha.colors as $mocha
        | .colors |= map_values(
          if test("^[a-z0-9]+(/[0-9]+)?$") | not
          then .
          else
            split("/") as [$name, $alpha]
            | ($mocha[$name] // error("unknown colour \($name)")) as $c
            | if $alpha
              then "rgba(\($c.rgb.r), \($c.rgb.g), \($c.rgb.b), \(($alpha | tonumber) / 100))"
              else $c.hex
              end
          end
        )
      ' ${named} > $out
    '';

    enforce = pkgs.writeShellApplication {
      name = "onlyoffice-theme";
      runtimeInputs = [pkgs.coreutils pkgs.gnugrep pkgs.crudini];
      text = ''
        themes=''${XDG_DATA_HOME:-$HOME/.local/share}/onlyoffice/desktopeditors/uithemes
        config=''${XDG_CONFIG_HOME:-$HOME/.config}/onlyoffice/DesktopEditors.conf
        mkdir -p "$themes" "''${config%/*}"
        ln -sfn ${theme} "$themes/${id}.json"

        # custom themes are picked by file path, not id
        # crudini is slow, skip it when already set
        if ! grep -qxF "UITheme=$themes/${id}.json" "$config" 2>/dev/null; then
          crudini --ini-options=nospace --set "$config" General UITheme "$themes/${id}.json"
        fi
      '';
    };
  in {
    packages.onlyoffice = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.onlyoffice-desktopeditors;
      }
      {
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}

{
  # DMS's settings from ~/.config/niri/dms/, last so DMS wins
  # raw lines: DMS's include check misses toKdl's quoted `include`
  flake.nixosModules.wniri-dms = {lib, ...}: {
    settings.extraConfig =
      lib.concatMapStrings (name: ''
        include optional=true "~/.config/niri/dms/${name}.kdl"
      '') ["colors" "layout" "alttab" "binds" "outputs" "cursor" "input" "windowrules" "wpblur"]
      # windowFx's close/open shaders, after DMS so they win
      + ''
        include optional=true "~/.config/niri/windowfx.kdl"
      '';
  };
}

{
  # DMS's settings from ~/.config/niri/dms/, last so DMS wins
  # raw lines: DMS's include check misses toKdl's quoted `include`
  flake.nixosModules.wniri-dms = {lib, ...}: {
    settings.extraConfig = lib.concatMapStrings (name: ''
      include optional=true "~/.config/niri/dms/${name}.kdl"
    '') ["colors" "layout" "alttab" "binds" "outputs" "cursor" "input" "windowrules" "wpblur"];
  };
}

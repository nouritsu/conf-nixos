{
  # Dux's settings from ~/.config/niri/dms/, last so Dux wins
  # raw lines: Dux's include check misses toKdl's quoted `include`
  flake.nixosModules.wniri-dux = {lib, ...}: {
    settings.extraConfig =
      lib.concatMapStrings (name: ''
        include optional=true "~/.config/niri/dms/${name}.kdl"
      '') ["colors" "layout" "alttab" "binds" "outputs" "cursor" "input" "windowrules" "wpblur"]
      # windowFx's close/open shaders, after Dux so they win
      + ''
        include optional=true "~/.config/niri/windowfx.kdl"
      '';
  };
}

{...}: {
  programs.waybar.settings.default.idle_inhibitor = {
    format = "{icon}";
    format-icons = {
      activated = "󰅶 ";
      deactivated = "󰾫 ";
    };
    min-length = 3;
    max-length = 3;
    tooltip-format-activated = "<b>Idle Inhibitor</b>: Activated";
    tooltip-format-deactivated = "<b>Idle Inhibitor</b>: Deactivated";
    start-activated = false;
  };
}

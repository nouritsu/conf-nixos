{...}: {
  programs.waybar.settings.default = {
    modules-left = [
      "group/gworkspaces"
      "group/gwindows"
    ];

    modules-right = [
      "group/gstatline"
      "group/gtray"
    ];
  };
}

{...}: {
  imports = [
    ./windowcount.h.nix
    ./window.h.nix
  ];

  programs.waybar.settings.default = {
    "group/gwindows" = {
      orientation = "inherit";
      modules = [
        "hyprland/windowcount"
        "hyprland/window"
      ];
    };
  };
}

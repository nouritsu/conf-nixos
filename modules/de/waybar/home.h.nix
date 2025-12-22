{...}: {
  imports = [
    ./styles/home.h.nix
    ./layout.h.nix
    ./modules/home.h.nix
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.default = {
      layer = "top";
      position = "top";
      mode = "dock";
      exclusive = true;
      passthrough = false;
      gtk-layer-shell = true;
      height = 0;
      spacing = 0;
      fixed-center = true;
      reload_style_on_change = true;
    };
  };
}

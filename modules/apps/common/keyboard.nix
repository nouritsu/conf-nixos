{...}: {
  # Console keyboard configuration
  console.keyMap = "us";

  # X11 keyboard configuration (for X11 apps under Wayland)
  services.xserver.xkb = {
    layout = "eu";
    variant = "";
    options = "";
  };
}

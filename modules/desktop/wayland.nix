{
  flake.nixosModules.desktop-wayland = {...}: {
    environment.variables = {
      XDG_SESSION_TYPE = "wayland";
    };
  };
}

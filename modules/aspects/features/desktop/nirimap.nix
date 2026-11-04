{inputs, ...}: let
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  den.aspects.nirimap.nixos = {
    self',
    pkgs,
    lib,
    ...
  }: let
    nirimap = self'.packages.nirimap;

    # the rest of its defaults are already mocha
    settings = (pkgs.formats.toml {}).generate "nirimap.toml" {
      display = {
        anchor = "top-right";
        # struts + gaps, so it lines up with windows
        margin_x = 9;
        margin_y = 9;
      };
      appearance = {
        focused_color = "#${palette.base0E}";
        active_workspace_border_color = "#${palette.base0E}";
      };
      behavior.overview_only = true;
    };
  in {
    environment.systemPackages = [nirimap];

    # reloads on change; it only writes a default when the file is missing
    systemd.user.tmpfiles.rules = [
      "L+ %h/.config/nirimap/config.toml - - - - ${settings}"
    ];

    systemd.user.services.nirimap = {
      description = "niri workspace minimap";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = lib.getExe nirimap;
        Restart = "on-failure";
      };
    };
  };
}

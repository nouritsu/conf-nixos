{inputs, ...}: {
  flake.nixosModules.app-hyprpicker = {...}: {
    my.hmModules = ["app-hyprpicker"];
  };

  flake.homeModules.app-hyprpicker = {
    pkgs,
    osConfig,
    ...
  }: let
    wezterm-pkg = inputs.wezterm.packages.${osConfig.my.system.arch}.default;

    colour-picker = pkgs.writeShellApplication {
      name = "colour-picker";
      runtimeInputs = [
        pkgs.hyprpicker
        wezterm-pkg
        pkgs.pastel
      ];
      text = ''
        colour=$(hyprpicker --autocopy --lowercase-hex)
        if [ -n "$colour" ]; then
          wezterm start --class colour-info -- sh -c "printf '\033[?25l'; echo ''${colour#\#} | pastel color; read -s -r"
        fi
      '';
    };
  in {
    home.packages = [
      colour-picker
    ];

    # TODO: MOVE TO NIRI
  };
}

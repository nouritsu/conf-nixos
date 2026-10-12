{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  inherit (nix-colors.colorSchemes.catppuccin-mocha) palette;
  inherit (nix-colors.lib.conversions) hexToRGB;

  rgb = slot: let
    c = hexToRGB palette.${slot};
  in {
    rgb = {
      r = builtins.elemAt c 0;
      g = builtins.elemAt c 1;
      b = builtins.elemAt c 2;
    };
  };
in {
  perSystem = {pkgs, ...}: {
    packages.tealdeer = wrappers.wrappers.tealdeer.wrap [
      {
        inherit pkgs;
        package = pkgs.tealdeer;
      }
      {
        settings = {
          updates = {
            auto_update = true;
            auto_update_interval_hours = 24;
          };

          # no catppuccin port; mauve for every highlight
          style = {
            description.foreground = rgb "base05";
            example_text.foreground = rgb "base0B";
            example_code.foreground = rgb "base05";
            command_name = {
              foreground = rgb "base0E";
              bold = true;
            };
            example_variable = {
              foreground = rgb "base0E";
              underline = true;
            };
          };
        };
      }
    ];
  };
}

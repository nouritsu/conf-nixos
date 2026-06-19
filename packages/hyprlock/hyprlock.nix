{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  palette = nix-colors.colorSchemes.catppuccin-mocha.palette;
  inherit (nix-colors.lib.conversions) hexToRGBString;
  to_rgb = base: "rgb(${hexToRGBString ", " palette.${base}})";
  to_rgba = base: alpha: "rgba(${hexToRGBString ", " palette.${base}}, ${toString alpha})";
in {
  perSystem = {pkgs, ...}: {
    packages.hyprlock = wrappers.wrappers.hyprlock.wrap [
      {
        inherit pkgs;
        package = pkgs.hyprlock;
      }
      {
        settings = {
          general = {
            hide_cursor = false;
            ignore_empty_input = true;
          };

          background = [
            {
              monitor = "";
              path = "screenshot";
              blur_passes = 3;
              blur_size = 7;
              brightness = 0.35;
              vibrancy = 0.25;
            }
          ];

          input-field = [
            {
              monitor = "";
              size = "450, 75";
              outline_thickness = 2;

              dots_size = 0.2;
              dots_spacing = 0.3;
              dots_center = true;

              outer_color = to_rgba "base05" 0;
              inner_color = to_rgba "base05" 0.1;
              font_color = to_rgb "base05";
              check_color = to_rgb "base0B"; # green when authenticating
              fail_color = to_rgb "base08"; # red when authentication fails
              capslock_color = to_rgb "base0A"; # catppuccin yellow when caps lock is on
              fail_text = "<b>failed</b>";
              fade_on_empty = false;

              placeholder_text = ''Log into <span foreground="##${palette.base0E}">~$USER</span>'';
              hide_input = false;

              position = "0, 0";
              halign = "center";
              valign = "center";
            }
          ];

          shape = [
            {
              monitor = "";
              size = "75, 75";
              color = to_rgb "base0D"; # blue (closest to sapphire in base16)
              rounding = -1;
              border_size = 0;
              onclick = "systemctl reboot";

              position = "-280, 0";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              size = "75, 75";
              color = to_rgb "base08"; # red
              rounding = -1;
              border_size = 0;
              onclick = "systemctl poweroff";

              position = "280, 0";
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            {
              monitor = "";
              text = "<span>   </span>";
              color = to_rgb "base01"; # mantle (dark text)
              font_size = 40;
              font_family = "JetBrainsMono Nerd Font Propo";

              position = "284, 0";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              text = "<span>   </span>";
              color = to_rgb "base01"; # mantle (dark text)
              font_size = 40;
              font_family = "JetBrainsMono Nerd Font Mono";

              position = "-272, 0";
              halign = "center";
              valign = "center";
            }
            # date / time
            {
              monitor = "";
              text = "cmd[update:60000] echo \"<span foreground='##${palette.base09}'>$(date +'%d-%m-%Y')</span>  ·  <span foreground='##${palette.base09}'>$(date +'%H:%M')</span>\"";
              color = to_rgb "base09"; # peach
              font_size = 16;
              font_family = "JetBrainsMono Nerd Font Propo";

              position = "0, -70";
              halign = "center";
              valign = "center";
            }
            # kb / attempts
            {
              monitor = "";
              text = ''cmd[update:1000] LOWER=$(echo "''$LAYOUT" | tr '[:upper:]' '[:lower:]'); if [ "''$ATTEMPTS" = "0" ]; then echo "<span foreground='##${palette.base07}'>''$LOWER</span>  ·  <span foreground='##${palette.base0B}'>ready</span>"; else echo "<span foreground='##${palette.base07}'>''$LOWER</span>  ·  <span foreground='##${palette.base08}'>(''$ATTEMPTS)</span>"; fi'';
              color = to_rgb "base07"; # lavender
              font_size = 16;
              font_family = "JetBrainsMono Nerd Font Mono";

              position = "0, 70";
              halign = "center";
              valign = "center";
            }
          ];
        };
      }
    ];
  };
}

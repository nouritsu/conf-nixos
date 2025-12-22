{config, ...}: let
  colors = config.lib.stylix.colors;
in {
  programs.waybar.style =
    /*
    css
    */
    ''
      @define-color rosewater #${colors.base06};
      @define-color flamingo #${colors.base0F};
      @define-color pink #f5c2e7;
      @define-color mauve #${colors.base0E};
      @define-color red #${colors.base08};
      @define-color maroon #eba0ac;
      @define-color peach #${colors.base09};
      @define-color yellow #${colors.base0A};
      @define-color green #${colors.base0B};
      @define-color teal #${colors.base0C};
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #${colors.base0D};
      @define-color lavender #${colors.base07};
      @define-color text #${colors.base05};
      @define-color subtext1 #${colors.base04};
      @define-color subtext0 #${colors.base04};
      @define-color overlay2 #${colors.base03};
      @define-color overlay1 #${colors.base03};
      @define-color overlay0 #${colors.base03};
      @define-color surface2 #${colors.base03};
      @define-color surface1 #${colors.base03};
      @define-color surface0 #${colors.base03};
      @define-color base #${colors.base02};
      @define-color mantle #${colors.base01};
      @define-color crust #${colors.base00};
    ''
    + builtins.readFile ./styles.css;
}

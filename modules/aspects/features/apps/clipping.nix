{
  den.aspects.extra.provides.clipping.nixos = {pkgs, ...}: let
    # catppuccin mocha over the hardcoded colours: white -> text, opaque black -> crust,
    # red/green -> red/green, vendor tints -> mauve, greys -> base/mantle/overlay
    palette = ''
      sed -i -E \
        -e 's/mgl::Color\(255, 255, 255/mgl::Color(205, 214, 244/g' \
        -e 's/mgl::Color\(0, 0, 0(, [1-9][0-9]*)?\)/mgl::Color(17, 17, 27\1)/g' \
        -e 's/mgl::Color\(255, 0, 0/mgl::Color(243, 139, 168/g' \
        -e 's/mgl::Color\(0, 255, 0/mgl::Color(166, 227, 161/g' \
        -e 's/mgl::Color\((221, 0, 49|118, 185, 0|8, 109, 183)\)/mgl::Color(203, 166, 247)/g' \
        -e 's/mgl::Color\(38, 43, 47\)/mgl::Color(30, 30, 46)/g' \
        -e 's/mgl::Color\(35, 40, 44\)/mgl::Color(24, 24, 37)/g' \
        -e 's/mgl::Color\(25, 30, 34\)/mgl::Color(30, 30, 46)/g' \
        -e 's/mgl::Color\(200, 200, 200\)/mgl::Color(127, 132, 156)/g' \
        -e 's/mgl::Color\(150, 150, 150\)/mgl::Color(147, 153, 178)/g' \
        $(grep -rlE 'mgl::Color\(' src include)
    '';

    notif = pkgs.gpu-screen-recorder-notification.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + palette
        + ''
          substituteInPlace src/main.cpp \
            --replace-fail '"76b900"' '"cba6f7"' \
            --replace-fail '"FFFFFF"' '"cdd6f4"'
        '';
    });
  in {
    programs.gpu-screen-recorder = {
      enable = true;
      ui = {
        enable = true;
        notifPackage = notif;
        package = (pkgs.gpu-screen-recorder-ui.override {gpu-screen-recorder-notification = notif;}).overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.imagemagick];
          postPatch =
            (old.postPatch or "")
            + ''
              # accent fills under text: translucent mauve, solid mauve kills contrast
              substituteInPlace src/gui/RadioButton.cpp --replace-fail \
                "selected_item ? get_color_theme().tint_color :" "selected_item ? mgl::Color(203, 166, 247, 80) :"
              substituteInPlace src/gui/ComboBox.cpp --replace-fail \
                "item_background.set_color(get_color_theme().tint_color)" "item_background.set_color(mgl::Color(203, 166, 247, 80))"
              substituteInPlace src/gui/FileChooser.cpp --replace-fail \
                "selected_item_background.set_color(get_color_theme().tint_color)" "selected_item_background.set_color(mgl::Color(203, 166, 247, 80))"
              for f in src/gui/SettingsPage.cpp src/gui/ScreenshotSettingsPage.cpp; do
                substituteInPlace $f --replace-fail \
                  '"save", get_color_theme().tint_color)' '"save", mgl::Color(203, 166, 247, 80))'
              done
            ''
            + palette
            + ''
              substituteInPlace src/Overlay.cpp --replace-fail \
                "bg_color(0, 0, 0, 100)" "bg_color(17, 17, 27, 100)"
              substituteInPlace src/main.cpp \
                --replace-fail '"ffffff"' '"cdd6f4"' \
                --replace-fail '"ff0000"' '"f38ba8"'
              substituteInPlace depends/mglpp/depends/mgl/src/graphics/text.c --replace-fail \
                "(mgl_color){255, 255, 255, 255}" "(mgl_color){205, 214, 244, 255}"

              # icons with baked-in colours; two-colour remap keeps the antialiasing
              recolor() {
                magick "images/$1" \( +clone -channel "$2" -separate +channel -level "$3" +level-colors "$4" \) \
                  +swap -compose CopyAlpha -composite "PNG32:images/$1"
              }
              recolor delete.png G 0,100% '#f38ba8,#11111b'
              recolor info.png R 27.45%,100% '#89b4fa,#11111b'
              recolor question_mark.png R 27.45%,100% '#89b4fa,#11111b'
              recolor warning.png R 0,100% '#11111b,#f9e2af'

              # no keyboard grab; niri binds drive gsr-ui-cli
              substituteInPlace include/Config.hpp --replace-fail \
                'hotkeys_enable_option = "enable_hotkeys"' 'hotkeys_enable_option = "disable_hotkeys"'
            '';
        });
      };
    };
  };
}

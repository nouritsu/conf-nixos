{inputs, ...}: let
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
  inherit (inputs.nix-colors.lib.conversions) hexToRGB;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    rgb = hex: lib.concatMapStringsSep ", " (c: toString (c / 255.0)) (hexToRGB hex);
  in {
    # nixos snowflake pulsing on mocha
    packages.plymouth-snowflake = pkgs.runCommand "plymouth-snowflake" {nativeBuildInputs = [pkgs.librsvg];} ''
      dir=$out/share/plymouth/themes/snowflake
      mkdir -p $dir

      # dark blues to mauve, light blues to lavender
      sed -E \
        -e 's/#(415e9a|4a6baf|5277c3)/#${palette.base0E}/g' \
        -e 's/#(699ad7|7eb1dd|7ebae4)/#${palette.base07}/g' \
        ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg > snowflake.svg
      rsvg-convert -w 512 snowflake.svg -o $dir/snowflake.png

      # the disk unlock's key: text colour while waiting, mauve once a security key opens it
      key=${pkgs.adwaita-icon-theme}/share/icons/Adwaita/symbolic/status/dialog-password-symbolic.svg
      sed 's/#2e3436/#${palette.base05}/' $key > key.svg
      sed 's/#2e3436/#${palette.base0E}/' $key > key-done.svg
      rsvg-convert -w 256 -h 256 key.svg -o $dir/key.png
      rsvg-convert -w 256 -h 256 key-done.svg -o $dir/key-done.png

      substitute ${./snowflake.script} $dir/snowflake.script \
        --subst-var-by base "${rgb palette.base00}" \
        --subst-var-by mauve "${rgb palette.base0E}"

      cat > $dir/snowflake.plymouth <<EOF
      [Plymouth Theme]
      Name=snowflake
      ModuleName=script

      [script]
      ImageDir=$dir
      ScriptFile=$dir/snowflake.script
      EOF
    '';
  };
}

{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  inherit (nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: let
    gio = lib.getExe' pkgs.glib "gio";
    wl-copy = lib.getExe' pkgs.wl-clipboard-rs "wl-copy";
  in {
    packages.imv = wrappers.wrappers.imv.wrap [
      {
        inherit pkgs;
        package = pkgs.imv;
      }
      {
        # port first; keys below override it
        constructFiles.imvconfig.builder = ''cat ${inputs'.catppuccin.packages.imv}/mocha.config "$1" > "$2"'';

        settings = {
          options = {
            scaling_mode = "shrink";
            overlay_font = "Maple Mono NF:18";
            overlay_text_color = palette.base0E;
          };

          # no space before ; or it reads as a comment
          binds = {
            "<Delete>" = ''exec ${gio} trash "$imv_current_file"; close'';
            y = ''exec ${wl-copy} < "$imv_current_file"'';
            w = ''exec dms ipc call wallpaper set "$(realpath "$imv_current_file")"'';
            "<Ctrl+Shift+R>" = "rotate by -90";
            "<Shift+H>" = "flip horizontal";
            "<Shift+V>" = "flip vertical";
          };
        };
      }
    ];
  };
}

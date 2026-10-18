{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.mpv = wrappers.wrappers.mpv.wrap [
      {
        inherit pkgs;
        package = pkgs.mpv;
      }
      {
        script = {
          mpris.path = pkgs.mpvScripts.mpris;
          uosc.path = pkgs.mpvScripts.uosc;
          thumbfast.path = pkgs.mpvScripts.thumbfast;
          sponsorblock.path = pkgs.mpvScripts.sponsorblock;
          quality-menu.path = pkgs.mpvScripts.quality-menu;
        };

        "mpv.conf".content = ''
          include="${inputs'.catppuccin.packages.mpv}/mocha/mauve.conf"

          # uosc draws its own
          osc=no
          osd-bar=no
        '';

        "mpv.input".content = ''
          F script-binding quality_menu/video_formats_toggle
          Alt+f script-binding quality_menu/audio_formats_toggle
        '';
      }
    ];
  };
}

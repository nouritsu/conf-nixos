{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # window app-id, see jellyfin_mpv_shim/constants.py
    id = "com.github.iwalton3.jellyfin-mpv-shim";

    desktop = pkgs.makeDesktopItem {
      name = id;
      desktopName = "Jellyfin MPV Shim";
      comment = "Browse and play the Jellyfin library in mpv";
      exec = lib.getExe pkgs.jellyfin-mpv-shim;
      icon = "jellyfin-mpv-shim";
      categories = ["AudioVideo" "Video" "Player" "TV"];
      startupWMClass = id;
    };
  in {
    # nixpkgs ships jellyfin-mpv-shim.desktop, which the window never matches
    packages.jellyfin-mpv-shim = pkgs.symlinkJoin {
      name = "jellyfin-mpv-shim";
      paths = [pkgs.jellyfin-mpv-shim];
      postBuild = ''
        rm $out/share/applications/jellyfin-mpv-shim.desktop
        install -Dm444 ${desktop}/share/applications/${id}.desktop -t $out/share/applications
      '';
      meta.mainProgram = "jellyfin-mpv-shim";
    };
  };
}

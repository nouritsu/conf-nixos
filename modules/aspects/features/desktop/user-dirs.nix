{
  den.aspects.user-dirs.nixos = {pkgs, ...}: let
    # $HOME turns templates and public off
    dirs = pkgs.writeText "user-dirs.dirs" ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOCUMENTS_DIR="$HOME/Documents"
      XDG_DOWNLOAD_DIR="$HOME/Downloads"
      XDG_MUSIC_DIR="$HOME/Music"
      XDG_PICTURES_DIR="$HOME/Pictures"
      XDG_PROJECTS_DIR="$HOME/Projects"
      XDG_VIDEOS_DIR="$HOME/Videos"
      XDG_TEMPLATES_DIR="$HOME"
      XDG_PUBLICSHARE_DIR="$HOME"
    '';
  in {
    systemd.user.tmpfiles.rules =
      ["L+ %h/.config/user-dirs.dirs - - - - ${dirs}"]
      ++ map (dir: "d %h/${dir} :0755") ["Desktop" "Documents" "Downloads" "Music" "Pictures" "Projects" "Videos"];
  };
}

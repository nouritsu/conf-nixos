{
  flake.nixosModules.wyazi-plugins = {pkgs, ...}: let
    bundle = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "plugins";
      rev = "05234ed15876ea80e1f4f05695e8e90c1fd5ab60";
      hash = "sha256-UJ2ICrp9LQBuuR/NpZvKsvFd/C1TRtTjK4ESNA6xh7k=";
    };

    yatline = pkgs.fetchFromGitHub {
      # https://github.com/carlosedp/yatline.yazi
      owner = "carlosedp";
      repo = "yatline.yazi";
      rev = "61d3a3a3310c74dfcf636c76e53ba388a019a3b5";
      hash = "sha256-XLnFRuvU4O5CbF7vO044iU6IXG8ojPyVjVR/8r7MGPc=";
    }; # default does not work on yazi-nightly

    path-from-root = pkgs.fetchFromGitHub {
      # https://github.com/aresler/path-from-root.yazi
      owner = "aresler";
      repo = "path-from-root.yazi";
      rev = "c4f03df864f09f9d2c4d585411f61c64de5954de";
      hash = "sha256-dQjZwRT1aMo3u0YuR+g036iQANTXnndaDQ3AoJ1yb1k=";
    };
  in {
    plugins = {
      inherit yatline path-from-root;
      yatline-catppuccin = pkgs.yaziPlugins.yatline-catppuccin;
      piper = pkgs.yaziPlugins.piper;
      ouch = pkgs.yaziPlugins.ouch;
      mediainfo = pkgs.yaziPlugins.mediainfo;
      wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
      duckdb = pkgs.yaziPlugins.duckdb;
      full-border = pkgs.yaziPlugins.full-border;
      git = pkgs.yaziPlugins.git;
      zoom = "${bundle}/zoom.yazi";
      smart-filter = "${bundle}/smart-filter.yazi";
      smart-enter = "${bundle}/smart-enter.yazi";
      smart-paste = "${bundle}/smart-paste.yazi";
      mount = "${bundle}/mount.yazi";
    };

    # tools the previewers/preloaders shell out to
    runtimePkgs = with pkgs; [mediainfo ouch glow hexyl duckdb];
  };
}

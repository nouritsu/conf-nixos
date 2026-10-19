{
  flake.nixosModules.wyazi-plugins = {pkgs, ...}: let
    bundle = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "plugins";
      rev = "05234ed15876ea80e1f4f05695e8e90c1fd5ab60";
      hash = "sha256-UJ2ICrp9LQBuuR/NpZvKsvFd/C1TRtTjK4ESNA6xh7k=";
    };

    yatline = pkgs.applyPatches {
      name = "yatline.yazi";
      src = pkgs.fetchFromGitHub {
        # https://github.com/carlosedp/yatline.yazi
        owner = "carlosedp";
        repo = "yatline.yazi";
        rev = "61d3a3a3310c74dfcf636c76e53ba388a019a3b5";
        hash = "sha256-XLnFRuvU4O5CbF7vO044iU6IXG8ojPyVjVR/8r7MGPc=";
      }; # default does not work on yazi-nightly
      # File:icon() removed upstream, use th.icon:match
      postPatch = ''
        substituteInPlace main.lua --replace-fail \
          'local icon = hovered:icon().text' \
          'local icon = (th.icon:match(hovered, { hovered = true }) or {}).text or ""'
      '';
    };

    # run_query returns nil when duckdb fails (e.g. a .txt that isn't csv)
    duckdb = pkgs.applyPatches {
      name = "duckdb.yazi";
      src = pkgs.yaziPlugins.duckdb;
      postPatch = ''
        substituteInPlace main.lua \
          --replace-fail 'tostring(output.stdout)' 'tostring(output and output.stdout)' \
          --replace-fail 'tostring(output.stderr)' 'tostring(output and output.stderr)' \
          --replace-fail 'local cleaned = output.stdout and' 'local cleaned = output and output.stdout and'
      '';
    };

    path-from-root = pkgs.fetchFromGitHub {
      # https://github.com/aresler/path-from-root.yazi
      owner = "aresler";
      repo = "path-from-root.yazi";
      rev = "c4f03df864f09f9d2c4d585411f61c64de5954de";
      hash = "sha256-dQjZwRT1aMo3u0YuR+g036iQANTXnndaDQ3AoJ1yb1k=";
    };
  in {
    plugins = {
      inherit yatline path-from-root duckdb;
      yatline-catppuccin = pkgs.yaziPlugins.yatline-catppuccin;
      piper = pkgs.yaziPlugins.piper;
      ouch = pkgs.yaziPlugins.ouch;
      mediainfo = pkgs.yaziPlugins.mediainfo;
      wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
      full-border = pkgs.yaziPlugins.full-border;
      git = pkgs.yaziPlugins.git;
      zoom = "${bundle}/zoom.yazi";
      smart-filter = "${bundle}/smart-filter.yazi";
      smart-enter = "${bundle}/smart-enter.yazi";
      smart-paste = "${bundle}/smart-paste.yazi";
      mount = "${bundle}/mount.yazi";
      chmod = "${bundle}/chmod.yazi";
      diff = "${bundle}/diff.yazi";
      toggle-pane = "${bundle}/toggle-pane.yazi";
      jump-to-char = "${bundle}/jump-to-char.yazi";
    };

    # tools the previewers/preloaders shell out to
    runtimePkgs = with pkgs; [mediainfo ouch glow hexyl duckdb];
  };
}

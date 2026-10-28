{
  flake.nixosModules.wyazi-plugins = {pkgs, ...}: let
    # File:icon() removed on nightly, use th.icon:match
    yatline = pkgs.applyPatches {
      name = "yatline.yazi";
      src = pkgs.yaziPlugins.yatline;
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
  in {
    plugins = {
      inherit yatline duckdb;
      yatline-catppuccin = pkgs.yaziPlugins.yatline-catppuccin;
      piper = pkgs.yaziPlugins.piper;
      ouch = pkgs.yaziPlugins.ouch;
      mediainfo = pkgs.yaziPlugins.mediainfo;
      wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
      full-border = pkgs.yaziPlugins.full-border;
      git = pkgs.yaziPlugins.git;
      zoom = pkgs.yaziPlugins.zoom;
      smart-filter = pkgs.yaziPlugins.smart-filter;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      smart-paste = pkgs.yaziPlugins.smart-paste;
      mount = pkgs.yaziPlugins.mount;
      chmod = pkgs.yaziPlugins.chmod;
      diff = pkgs.yaziPlugins.diff;
      toggle-pane = pkgs.yaziPlugins.toggle-pane;
      jump-to-char = pkgs.yaziPlugins.jump-to-char;
    };

    # tools the previewers/preloaders shell out to
    runtimePkgs = with pkgs; [mediainfo ouch glow hexyl duckdb];
  };
}

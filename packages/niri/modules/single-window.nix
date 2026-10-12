{
  flake.nixosModules.wniri-single-window = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # rule-set widths are kept
    sized = lib.concatMap (r: lib.catAttrs "app-id" r.matches) (
      lib.filter (r: r ? default-column-width) config.settings.window-rules
    );

    # emits "<id> <width>": full width while alone, default once another column joins
    filter = pkgs.writeText "single-window.jq" ''
      def sized: (.app_id // "") as $a | any(${builtins.toJSON sized}[] as $re | $a | test($re); .);

      foreach inputs as $e ({windows: {}, maxed: {}};
        .out = []
        | if $e.WindowsChanged then
            .windows = ($e.WindowsChanged.windows | map({key: (.id | tostring), value: .}) | from_entries)
          elif $e.WindowOpenedOrChanged then
            .windows[$e.WindowOpenedOrChanged.window.id | tostring] = $e.WindowOpenedOrChanged.window
          elif $e.WindowClosed then
            del(.windows[$e.WindowClosed.id | tostring], .maxed[$e.WindowClosed.id | tostring])
          elif $e.WindowLayoutsChanged then
            reduce $e.WindowLayoutsChanged.changes[] as [$id, $layout] (.;
              if .windows[$id | tostring] then .windows[$id | tostring].layout = $layout end)
          end
        | . as $s
        | reduce ([.windows[] | select(.layout.pos_in_scrolling_layout)] | group_by(.workspace_id))[] as $ws (.;
            [$ws[].id | tostring | select($s.maxed[.])] as $mine
            | if ($ws | map(.layout.pos_in_scrolling_layout[0]) | unique | length) > 1 then
                reduce $mine[] as $id (.; del(.maxed[$id]) | .out += ["\($id) 50%"])
              elif $mine == [] and ($ws | any(.[]; sized) | not) then
                .maxed[$ws[0].id | tostring] = true | .out += ["\($ws[0].id) 100%"]
              end);
        .out[])
    '';

    watcher = pkgs.writeShellApplication {
      name = "niri-single-window";
      runtimeInputs = [config.package pkgs.jq];
      text = ''
        niri msg --json event-stream | jq -nr --unbuffered -f ${filter} | while read -r id width; do
          niri msg action set-window-width --id "$id" "$width" || true
        done
      '';
    };
  in {
    settings = {
      layout.always-center-single-column = _: {};
      spawn-at-startup = [(lib.getExe watcher)];
    };
  };
}

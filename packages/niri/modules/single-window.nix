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

    # emits ids to maximise: a workspace's lone column, once focused; later columns leave it alone
    filter = pkgs.writeText "single-window.jq" ''
      def sized: (.app_id // "") as $a | any(${builtins.toJSON sized}[] as $re | $a | test($re); .);

      foreach inputs as $e ({windows: {}, maxed: {}, focus: null};
        .out = []
        | if $e.WindowsChanged then
            .windows = ($e.WindowsChanged.windows | map({key: (.id | tostring), value: .}) | from_entries)
            | .focus = ($e.WindowsChanged.windows | map(select(.is_focused).id) | first)
          elif $e.WindowOpenedOrChanged then
            $e.WindowOpenedOrChanged.window as $w
            | .windows[$w.id | tostring] = $w
            | if $w.is_focused then .focus = $w.id elif .focus == $w.id then .focus = null end
          elif $e.WindowFocusChanged then
            .focus = $e.WindowFocusChanged.id
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
                del(.maxed[$mine[]])
              elif $mine == [] and ($ws | any(.[]; sized) | not) and any($ws[]; .id == $s.focus) then
                .maxed[$s.focus | tostring] = true | .out += ["\($s.focus)"]
              end);
        .out[])
    '';

    watcher = pkgs.writeShellApplication {
      name = "niri-single-window";
      runtimeInputs = [config.package pkgs.jq];
      text = ''
        # a real maximise so Mod+M undoes it; it only toggles, so a column already full is skipped
        niri msg --json event-stream | jq -nr --unbuffered -f ${filter} | while read -r id; do
          out=$(niri msg --json focused-output) || continue
          niri msg --json focused-window \
            | jq -e --argjson id "$id" --argjson out "$out" \
              '.id == $id and .layout.tile_size[0] < $out.logical.width * 0.75' >/dev/null \
            || continue
          niri msg action maximize-column || true
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

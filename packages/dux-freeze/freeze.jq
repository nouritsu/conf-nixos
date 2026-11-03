# . is a repo file; out: {settings, applied, conflicts}
# $base: what dux started from at the last switch, $live: dux now,
# $built: this host's build of the repo settings (settings only)

def absent: "\u0000absent";

def at($p):
  reduce $p[] as $k (.;
    if type == "object" and ($k | type) == "string" and has($k) then .[$k]
    elif type == "array" and ($k | type) == "number" and $k < length then .[$k]
    else absent
    end);

# into objects, and into arrays that kept their length
def leaves($a; $b):
  if ($a | type) == "object" and ($b | type) == "object" then
    ($a + $b | keys_unsorted[]) as $k
    | [$k] + leaves($a | at([$k]); $b | at([$k]))
  elif ($a | type) == "array" and ($b | type) == "array" and ($a | length) == ($b | length) then
    range($a | length) as $i
    | [$i] + leaves($a[$i]; $b[$i])
  else []
  end;

# same array lengths along $p, so its indices name the same element in both
def aligned($a; $b; $p):
  all(range($p | length) as $i | [($a | at($p[:$i])), ($b | at($p[:$i]))];
    ((.[0] | type) != "array" and (.[1] | type) != "array")
    or ((.[0] | type) == (.[1] | type) and (.[0] | length) == (.[1] | length)));

# a new key lands after the live key before it
def insert($k; $v; $order):
  . as $o
  | [$order[:($order | index($k))][] | select(. as $x | $o | has($x))] as $before
  | to_entries
  | (if $before == [] then 0 else (map(.key) | index($before[-1])) + 1 end) as $i
  | .[:$i] + [{key: $k, value: $v}] + .[$i:]
  | from_entries;

def put($p; $v; $order):
  if $v == absent then delpaths([$p])
  elif ($p[-1] | type) == "string" and at($p) == absent and (at($p[:-1]) | type) == "object" then
    setpath($p[:-1]; at($p[:-1]) | insert($p[-1]; $v; $order))
  else setpath($p; $v)
  end;

# repo: changed in the repo since the last switch too; host: this host's overrides rewrite it
def settings:
  . as $r
  | $base[0] as $g
  | $live[0] as $l
  | $built[0] as $n
  | reduce (leaves($g; $l) | select(. as $p | ($g | at($p)) != ($l | at($p)))) as $p
    ({settings: $r, applied: [], conflicts: []};
      if (aligned($g; $n; $p) | not) or (($n | at($p)) != ($g | at($p)) and ($n | at($p)) != ($l | at($p))) then
        .conflicts += [{path: $p, why: "repo"}]
      elif (aligned($r; $n; $p) | not) or ($r | at($p)) != ($n | at($p)) then
        .conflicts += [{path: $p, why: "host"}]
      else
        .settings |= put($p; $l | at($p); $l | at($p[:-1]) | if type == "object" then keys_unsorted else [] end)
        | .applied += [$p]
      end);

# only keys already pinned, so tokens and state stay out
def plugins:
  . as $r
  | $base[0] as $g
  | $live[0] as $l
  | reduce (keys_unsorted[] as $id | .[$id] | keys_unsorted[] | [$id, .]) as $p
    ({settings: $r, applied: [], conflicts: []};
      ($g | at($p)) as $gv
      | ($l | at($p)) as $lv
      | if $gv == absent or $lv == absent or $lv == $gv then .
        elif ($r | at($p)) != $gv and ($r | at($p)) != $lv then .conflicts += [{path: $p, why: "repo"}]
        else .settings |= setpath($p; $lv) | .applied += [$p]
        end);

if $kind == "settings" then settings else plugins end

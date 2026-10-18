# 3-way merge of the Balatro profile between the PC (Proton) and the phone (LMM over adb)

set -g pkg systems.shorty.lmm.balatro
set -g phone_save files/save/ASET
set -g files 1/profile.jkr 1/meta.jkr settings.jkr
set -g merge_lua @merge@
set -g verify_lua @verify@
set -g self (status filename)

set -g data $HOME/.local/share
set -q XDG_DATA_HOME[1]; and set data $XDG_DATA_HOME
set -g state $data/balatro-sync

# Theme
set -gx GUM_SPIN_SPINNER_FOREGROUND '#cba6f7'
set -gx GUM_CONFIRM_PROMPT_FOREGROUND '#cba6f7'
set -gx GUM_CONFIRM_SELECTED_FOREGROUND '#1e1e2e'
set -gx GUM_CONFIRM_SELECTED_BACKGROUND '#cba6f7'
set -gx GUM_CONFIRM_UNSELECTED_FOREGROUND '#cdd6f4'
set -gx GUM_CONFIRM_UNSELECTED_BACKGROUND '#313244'
set -gx GUM_INPUT_PROMPT_FOREGROUND '#cba6f7'
set -gx GUM_INPUT_CURSOR_FOREGROUND '#cba6f7'
set -gx GUM_INPUT_HEADER_FOREGROUND '#a6adc8'
set -gx GUM_INPUT_PLACEHOLDER_FOREGROUND '#6c7086'
set -gx GUM_TABLE_BORDER_FOREGROUND '#cba6f7'
set -gx GUM_TABLE_HEADER_FOREGROUND '#cba6f7'

# Output
function info
    gum log --level info --level.foreground '#89b4fa' "$argv"
end

function warn
    gum log --level warn --level.foreground '#f9e2af' "$argv"
end

function die
    gum log --level error --level.foreground '#f38ba8' "$argv"
    exit 1
end

# gum spin only runs commands, so steps rerun this script as `__step <function> <args>`
function spin --argument-names title
    gum spin --title $title --show-error -- $self __step $argv[2..]
end

# Saves are raw deflate, level 1
function inflate --argument-names src dst
    python3 -c 'import sys, zlib; sys.stdout.buffer.write(zlib.decompress(sys.stdin.buffer.read(), -15))' <$src >$dst
end

function deflate --argument-names src dst
    python3 -c '
import sys, zlib
s = sys.stdin.buffer.read()
c = zlib.compressobj(1, zlib.DEFLATED, -15)
e = c.compress(s) + c.flush()
assert zlib.decompress(e, -15) == s
sys.stdout.buffer.write(e)' <$src >$dst
end

function local_sha
    sha1sum $argv | string split -f1 ' '
end

function phone_sha
    adb shell run-as $pkg sha1sum $phone_save/$files 2>/dev/null | string split -f1 ' '
end

function pc_running
    pgrep -f '[B]alatro\.exe' >/dev/null
end

function phone_running
    adb shell pidof $pkg >/dev/null 2>&1
end

# files whose sha differs from steam cloud's last sync
function cloud_drift --argument-names save remotecache
    set -l vdf (string collect <$remotecache)
    for f in $files
        set -l key (string escape --style=regex -- "Balatro/$f")
        set -l cloud (string match -rg '"'$key'"\s*\{[^}]*"sha"\s+"([0-9a-f]+)"' -- $vdf)
        test "$cloud" = "$(local_sha $save/$f)"; or echo $f
    end
end

function save_base --argument-names src
    mkdir -p $state/base/1
    cp $src/1/profile.jkr $src/1/meta.jkr $state/base/1/
end

function write_pc --argument-names src dst
    for f in $files
        cat $src/$f >$dst/$f; or return
    end
end

# Steps
function wait_pc
    while pc_running
        sleep 1
    end
end

function wait_phone
    while phone_running
        sleep 1
    end
end

function wait_cloud --argument-names save remotecache
    for i in (seq 15)
        test -z "$(cloud_drift $save $remotecache)"; and return
        sleep 1
    end
    return 1
end

function pull_phone --argument-names run
    adb exec-out run-as $pkg tar -cf - -C $phone_save 1 config settings.jkr >$run/phone.tar
    and mkdir -p $run/phone
    and tar -xf $run/phone.tar -C $run/phone
end

function push_phone --argument-names src
    for f in $files
        adb exec-in run-as $pkg sh -c "cat > $phone_save/$f" <$src/$f; or return
    end
    # exec-in returns before the remote cat is done
    set -l want (local_sha $src/$files)
    for i in (seq 40)
        set -l have (phone_sha)
        test "$have" = "$want"; and return
        sleep 0.25
    end
    return 1
end

if test "$argv[1]" = __step
    $argv[2..]
    exit
end

if set -q argv[1]
    echo "usage: balatro-sync" >&2
    exit 2
end

gum style --border rounded --border-foreground '#cba6f7' --foreground '#cba6f7' --bold --padding '0 2' 'Balatro sync'

# PC save
set -l steam $data/Steam
set -l libraries $steam
test -f $steam/steamapps/libraryfolders.vdf
and set -a libraries (string match -rg '^\s*"path"\s+"(.*)"\s*$' <$steam/steamapps/libraryfolders.vdf)
set -l exe
set -l pc_save
for lib in $libraries
    if test -f $lib/steamapps/common/Balatro/Balatro.exe
        set exe $lib/steamapps/common/Balatro/Balatro.exe
        set pc_save $lib/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro
        break
    end
end
test -n "$exe"; or die "Balatro isn't installed in any Steam library"
test -f $pc_save/1/profile.jkr; or die "no PC save at $pc_save"

set -l remotecache
if test -f $pc_save/steam_autocloud.vdf
    set -l account (string match -rg '"accountid"\s+"(\d+)"' <$pc_save/steam_autocloud.vdf)
    set remotecache $steam/userdata/$account/2379780/remotecache.vdf
end

# Base
if not test -f $state/base/1/profile.jkr -a -f $state/base/1/meta.jkr
    warn "no base save yet"
    set -l guesses ~/balatro-transfer-*/out/pc
    set -l guess
    test (count $guesses) -gt 0; and set guess $guesses[-1]
    set -l dir (gum input --header 'dir with the 1/profile.jkr + 1/meta.jkr last written to both sides' --value "$guess" --placeholder 'path')
    or exit 130
    test -f $dir/1/profile.jkr -a -f $dir/1/meta.jkr; or die "no 1/profile.jkr + 1/meta.jkr in $dir"
    save_base $dir
    info "base set from $dir"
end

# Preflight
if test "$(adb get-state 2>/dev/null)" != device
    gum spin --title 'waiting for the phone on adb' --timeout 2m -- adb wait-for-device
    or die "no phone on adb"
end
info "phone connected"

if pc_running
    spin 'quit Balatro on the PC' wait_pc; or exit 130
end
if phone_running
    spin 'close Balatro on the phone' wait_phone; or exit 130
end

if test -f "$remotecache"
    if not spin 'waiting for Steam Cloud to settle' wait_cloud $pc_save $remotecache
        warn "PC save differs from Steam Cloud's last sync: "(cloud_drift $pc_save $remotecache)
        gum confirm --default=false 'Steam may flag a cloud conflict on next launch. Continue?'; or exit 1
    end
else
    warn "no Steam Cloud state found, skipping the cloud check"
end

# Backups
set -l run $state/runs/(date +%Y%m%d-%H%M%S)
mkdir -p $run/pc $run/base $run/src $run/decoded/{base,pc,phone}/1 $run/out/{pc,phone}/1

cp -a (path filter $pc_save/{1,config,settings.jkr,steam_autocloud.vdf} $remotecache) $run/pc/
or die "couldn't back up the PC save"
info "backed up the PC save"

spin 'backing up the phone save' pull_phone $run; or die "couldn't pull the phone save"
for f in $files
    test -f $run/phone/$f; or die "phone save has no $f"
end
info "backed up the phone save"

cp -a $state/base/1 $run/base/

# Merge
unzip -qo $exe game.lua engine/string_packer.lua -d $run/src 2>/dev/null
test -f $run/src/game.lua -a -f $run/src/engine/string_packer.lua; or die "couldn't unpack the game source from $exe"

for side in base pc phone
    set -l want $files
    test $side = base; and set want $files[1..2]
    for f in $want
        inflate $run/$side/$f $run/decoded/$side/(string replace -r '\.jkr$' .lua $f)
        or die "couldn't decode the $side $f"
    end
end

set -l targets (luajit $merge_lua $run $run/src 2>$run/error.log)
or die "merge failed: "(head -n1 $run/error.log | string replace -r '^luajit: [^:]+:\d+: ' '')

gum table --print --file $run/summary.csv

set -l checks (luajit $verify_lua $run $run/src 2>$run/error.log)
set -l verified $status
for line in $checks
    info $line
end
test $verified -eq 0; or die "verify failed: "(head -n1 $run/error.log | string replace -r '^luajit: [^:]+:\d+: ' '')

for side in pc phone
    for f in $files
        deflate $run/out/$side/(string replace -r '\.jkr$' .lua $f) $run/out/$side/$f
        or die "couldn't encode the $side $f"
    end
end

if test (count $targets) -eq 0
    save_base $run/out/pc
    gum style --border rounded --border-foreground '#a6e3a1' --foreground '#a6e3a1' --padding '0 2' 'Already in sync'
    exit 0
end

# Write
gum confirm "Write the merged save to "(string join ' and ' $targets)"?"
or begin
    info "nothing written, run kept at $run"
    exit 1
end

pc_running; and die "Balatro started on the PC, nothing written"
phone_running; and die "Balatro started on the phone, nothing written"
test "$(local_sha $pc_save/$files)" = "$(local_sha $run/pc/$files)"
or die "PC save changed since the backup, nothing written"
set -l have (phone_sha)
set -l want (local_sha $run/phone/$files)
test "$have" = "$want"; or die "phone save changed since the backup, nothing written"

if contains phone $targets
    if not spin 'writing the phone save' push_phone $run/out/phone
        warn "phone write failed, putting its old save back"
        spin 'restoring the phone save' push_phone $run/phone
        or die "phone restore failed too, its backup is $run/phone.tar"
        die "phone write failed, both saves left as they were"
    end
    info "wrote the phone save"
end

# a side that missed the write keeps its old save, which is then the common base
if contains pc $targets
    if not write_pc $run/out/pc $pc_save
        warn "PC write failed, putting its old save back"
        write_pc $run/pc $pc_save; or warn "PC restore failed, its backup is $run/pc"
        save_base $run/pc
        die "PC write failed, base moved to the PC's old save"
    end
    info "wrote the PC save"
end

save_base $run/out/pc
gum style --border rounded --border-foreground '#a6e3a1' --foreground '#a6e3a1' --padding '0 2' "Synced "(string join ' + ' $targets) "backup: $run"

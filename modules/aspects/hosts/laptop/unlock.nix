{
  # a security key or the passphrase, whichever comes first, opens root; swap follows without asking
  den.aspects.laptop.nixos = {
    config,
    pkgs,
    lib,
    utils,
    ...
  }: let
    inherit (config.boot.initrd.luks.devices) cryptroot cryptswap;

    # root's volume key, linked here on unlock
    # the service's own session keyring: keys in root's @u aren't readable from it
    vk = "cryptroot-vk";

    # after a key unlock only: key-login opens the sealed login password with it, once
    loginKey = config.greeter'.diskLoginKeyFile;

    # disko's settings, for whichever tool opens the volume
    systemdFlags = d: lib.optional d.allowDiscards "discard" ++ lib.optionals d.bypassWorkqueues ["no-read-workqueue" "no-write-workqueue"];
    cryptsetupFlags = d: lib.concatStringsSep " " (lib.optional d.allowDiscards "--allow-discards" ++ lib.optionals d.bypassWorkqueues ["--perf-no_read_workqueue" "--perf-no_write_workqueue"]);

    # never prompts: asks the plugged-in keys for a touch, or logs that none of them fits
    keyOptions = lib.concatStringsSep "," (systemdFlags cryptroot
      ++ [
        "fido2-device=auto"
        "headless=true"
        "token-timeout=0"
        "link-volume-key=@s::${vk}"
      ]);

    devices = map (d: "${utils.escapeSystemdPath d.device}.device") [cryptroot cryptswap];

    # from root's volume key on stdin: swap's passphrase, and what the initrd leaves in loginKey
    derive = ''
      swap_passphrase() { sha256sum | cut -d' ' -f1 | tr -d '\n'; }
      login_key() { { cat; printf login; } | sha256sum | cut -d' ' -f1; }
    '';

    # root's volume key into $work/vk, given root's passphrase or recovery key
    dumpVolumeKey = ''
      work=$(mktemp -d -p /run)
      trap 'rm -rf "$work"' EXIT
      echo "root's passphrase or recovery key:" >&2
      cryptsetup luksDump --batch-mode --dump-volume-key --volume-key-file "$work/vk" ${cryptroot.device} > /dev/null
    '';

    # once, on the running system: adds swap's keyslot for root's volume key
    enrollSwapKey = pkgs.writeShellApplication {
      name = "enroll-swap-key";
      runtimeInputs = [pkgs.cryptsetup pkgs.coreutils];
      text = ''
        if [ "$(id -u)" != 0 ]; then
          echo "run it with sudo" >&2
          exit 1
        fi

        ${derive}
        ${dumpVolumeKey}
        swap_passphrase < "$work/vk" > "$work/swap"

        if cryptsetup open --test-passphrase --key-file "$work/swap" ${cryptswap.device} 2> /dev/null; then
          echo "swap already opens from root's key"
          exit 0
        fi
        echo "swap's passphrase:"
        # the key is random, so a slow hash would only slow down boot
        cryptsetup luksAddKey --pbkdf pbkdf2 --pbkdf-force-iterations 1000 ${cryptswap.device} "$work/swap"
      '';
    };

    # for seal-keyring, as root: what the initrd leaves in loginKey
    diskLoginKey = pkgs.writeShellApplication {
      name = "disk-login-key";
      runtimeInputs = [pkgs.cryptsetup pkgs.coreutils];
      text = ''
        ${derive}
        ${dumpVolumeKey}
        login_key < "$work/vk"
      '';
    };
  in {
    environment.systemPackages = [enrollSwapKey];

    greeter'.diskLoginKey = diskLoginKey;

    # if this fails, systemd's own unlock runs after it as before
    boot.initrd.systemd.services.unlock-disk = {
      description = "Unlock the disk with a security key or the passphrase";
      wantedBy = ["cryptsetup.target" "systemd-cryptsetup@cryptroot.service" "systemd-cryptsetup@cryptswap.service"];
      before = ["cryptsetup.target" "systemd-cryptsetup@cryptroot.service" "systemd-cryptsetup@cryptswap.service"];
      after = ["plymouth-start.service" "systemd-ask-password-plymouth.path"] ++ devices;
      requires = devices;
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "infinity";
      };
      # also copies them into the initrd
      path = [pkgs.coreutils pkgs.keyutils pkgs.cryptsetup config.boot.plymouth.package config.boot.initrd.systemd.package];
      script = ''
        umask 077
        shopt -s nullglob
        work=/run/unlock-disk
        mkdir -p "$work"
        trap 'rm -rf "$work"' EXIT

        # systemd's own unlock opened it after this failed once
        if [ -e /dev/mapper/cryptroot ]; then
          exit 0
        fi

        # the theme turns these into the hint under the flake
        say() {
          plymouth display-message --text="snowflake:$1" || true
        }

        # FIDO keys plugged in, by device number; smartcard readers are security devices too
        keys() {
          local tag id found=""
          for tag in /run/udev/tags/security-device/*; do
            id=''${tag##*/}
            if [ -e "/run/udev/data/$id" ] && [[ $(< "/run/udev/data/$id") == *E:ID_FIDO_TOKEN=1* ]]; then
              found+=" $id"
            fi
          done
          echo "$found"
        }

        # one systemd-cryptsetup per set of plugged-in keys, until one opens root
        # braces, not a subshell: run with &, so the TERM trap is in $key's process
        key_side() {
          attach="" refused="" said=""

          hint() {
            if [ "$1" != "$said" ]; then
              said=$1
              say "$1"
            fi
          }

          # 0 if it opened root before it could be stopped
          stop() {
            local status=0
            [ -n "$attach" ] || return 1
            kill "$attach" 2> /dev/null || true
            wait "$attach" || status=$?
            attach=""
            return "$status"
          }
          trap 'if stop; then exit 0; fi; exit 1' TERM

          while :; do
            plugged=$(keys)
            if [ -z "$plugged" ]; then
              refused=""
              hint plug
            elif [ "$plugged" != "$refused" ]; then
              : > "$work/attach.log"
              SYSTEMD_LOG_TARGET=console systemd-cryptsetup attach cryptroot ${cryptroot.device} - ${keyOptions} \
                2> >(tee -a "$work/attach.log" >&2) &
              attach=$!

              changed=""
              while kill -0 "$attach" 2> /dev/null; do
                if [ "$(keys)" != "$plugged" ]; then
                  changed=1
                  break
                fi
                case $(< "$work/attach.log") in
                  *"not present"*) break ;;
                  *"Please confirm presence"*) hint tap ;;
                esac
                sleep 0.25
              done

              if stop; then
                exit 0
              fi
              # a touch that never came gets asked for again
              if [ -z "$changed" ] && [[ $(< "$work/attach.log") != *"Please confirm presence"* ]]; then
                refused=$plugged
                hint wrong-key
              fi
            fi
            sleep 0.25
          done
        }

        start_key() {
          key_side &
          key=$!
        }
        # the theme draws a key while it's empty, dots once typing starts
        start_ask() {
          systemd-ask-password --no-tty --timeout=0 --id=unlock-disk:cryptroot "Unlock" > "$work/pass" &
          ask=$!
        }

        start_key
        start_ask
        while :; do
          wait -n -p finished "$key" "$ask" && status=0 || status=$?
          if [ "$finished" = "$key" ]; then
            if [ "$status" = 0 ]; then
              by=key
              break
            fi
            sleep 1
            start_key
          else
            pass=$(< "$work/pass")
            if [ -n "$pass" ]; then
              # one opener at a time; the key may have won meanwhile
              kill "$key" 2> /dev/null || true
              if wait "$key"; then
                by=key
                break
              fi
              say busy
              if printf %s "$pass" | cryptsetup open --type luks2 --key-file - ${cryptsetupFlags cryptroot} --link-vk-to-keyring @s::${vk} ${cryptroot.device} cryptroot; then
                by=passphrase
                break
              fi
              say wrong-pass
              start_key
            fi
            [ "$status" = 0 ] || sleep 1
            start_ask
          fi
        done
        unset pass
        say "$by-unlocked"

        ${derive}
        id=$(keyctl search @s user ${vk})
        # after a key unlock the greeter takes an empty password, the touch already happened
        if [ "$by" = key ]; then
          mkdir -p ${dirOf loginKey}
          keyctl pipe "$id" | login_key > ${loginKey}
        fi
        keyctl pipe "$id" | swap_passphrase > "$work/swap"
        keyctl revoke "$id"
        keyctl unlink "$id" @s

        open_swap() {
          cryptsetup open --type luks2 --key-file - ${cryptsetupFlags cryptswap} ${cryptswap.device} cryptswap
        }
        # plymouth keeps a prompt whose asker is gone, and queues later prompts behind it;
        # so until enroll-swap-key, swap's passphrase goes in the prompt still up after a key unlock
        if ! open_swap < "$work/swap"; then
          echo "swap doesn't open from root's key; sudo enroll-swap-key adds that"
          say swap
          while :; do
            kill -0 "$ask" 2> /dev/null || start_ask
            wait "$ask" || true
            pass=$(< "$work/pass")
            # nothing typed: systemd asks next
            if [ -z "$pass" ]; then
              break
            fi
            say busy
            if printf %s "$pass" | open_swap; then
              say passphrase-unlocked
              break
            fi
            say wrong-pass
          done
          unset pass
        fi
        kill "$ask" 2> /dev/null || true
      '';
    };
  };
}

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

    # root's volume key, linked here on unlock; swap's passphrase is its sha256
    vk = "cryptroot-vk";

    # disko's settings, for whichever tool opens the volume
    systemdFlags = d: lib.optional d.allowDiscards "discard" ++ lib.optionals d.bypassWorkqueues ["no-read-workqueue" "no-write-workqueue"];
    cryptsetupFlags = d: lib.concatStringsSep " " (lib.optional d.allowDiscards "--allow-discards" ++ lib.optionals d.bypassWorkqueues ["--perf-no_read_workqueue" "--perf-no_write_workqueue"]);

    # never prompts: waits for a key to be plugged in and touched
    keyOptions = lib.concatStringsSep "," (systemdFlags cryptroot
      ++ [
        "fido2-device=auto"
        "headless=true"
        "token-timeout=0"
        "link-volume-key=@u::${vk}"
      ]);

    devices = map (d: "${utils.escapeSystemdPath d.device}.device") [cryptroot cryptswap];

    # once, on the running system: adds swap's keyslot for root's volume key
    enrollSwapKey = pkgs.writeShellApplication {
      name = "enroll-swap-key";
      runtimeInputs = [pkgs.cryptsetup pkgs.coreutils];
      text = ''
        if [ "$(id -u)" != 0 ]; then
          echo "run it with sudo" >&2
          exit 1
        fi
        work=$(mktemp -d -p /run)
        trap 'rm -rf "$work"' EXIT

        echo "root's passphrase or recovery key:"
        cryptsetup luksDump --batch-mode --dump-volume-key --volume-key-file "$work/vk" ${cryptroot.device}
        sha256sum < "$work/vk" | cut -d' ' -f1 | tr -d '\n' > "$work/swap"

        echo "swap's passphrase:"
        cryptsetup luksAddKey ${cryptswap.device} "$work/swap"
      '';
    };
  in {
    environment.systemPackages = [enrollSwapKey];

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
      script = ''
        export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.keyutils pkgs.cryptsetup config.boot.plymouth.package config.boot.initrd.systemd.package]}

        work=/run/unlock-disk
        mkdir -p -m 700 "$work"
        trap 'rm -rf "$work"' EXIT
        # the volume key gets linked into it
        keyctl describe @u > /dev/null

        start_key() {
          systemd-cryptsetup attach cryptroot ${cryptroot.device} - ${keyOptions} &
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
          wait -n -p done "$key" "$ask" && status=0 || status=$?
          if [ "$done" = "$key" ]; then
            if [ "$status" = 0 ]; then
              plymouth display-message --text=snowflake:unlocked || true
              kill "$ask" 2> /dev/null || true
              break
            fi
            # no usable key yet; the prompt stays up meanwhile
            sleep 2
            start_key
          else
            pass=$(< "$work/pass")
            if [ -n "$pass" ] && printf %s "$pass" | cryptsetup open --type luks2 --key-file - ${cryptsetupFlags cryptroot} --link-vk-to-keyring @u::${vk} ${cryptroot.device} cryptroot; then
              kill "$key" 2> /dev/null || true
              break
            fi
            [ "$status" = 0 ] || sleep 1
            start_ask
          fi
        done
        unset pass

        id=$(keyctl search @u user ${vk})
        keyctl pipe "$id" | sha256sum | cut -d' ' -f1 | tr -d '\n' > "$work/swap"
        keyctl revoke "$id"
        keyctl unlink "$id" @u
        cryptsetup open --type luks2 --key-file "$work/swap" ${cryptsetupFlags cryptswap} ${cryptswap.device} cryptswap
      '';
    };
  };
}

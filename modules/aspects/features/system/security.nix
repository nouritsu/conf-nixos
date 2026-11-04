{den, ...}: {
  den.aspects.security = {
    nixos = {
      security.polkit.enable = true;
      security.sudo.enable = false;
      security.sudo-rs.enable = true;
    };

    provides.keyring.nixos = {
      pkgs,
      lib,
      ...
    }: {
      services.gnome.gnome-keyring.enable = true;

      environment.systemPackages = [
        pkgs.gcr_4
        pkgs.seahorse
      ];

      which-key'.menu.s.submenu.k = {
        desc = "Seahorse";
        icon = "f0306";
        cmd = lib.getExe pkgs.seahorse;
        app-id = "seahorse";
      };
    };

    # two security keys: a touch instead of the password, typing it still works
    provides.yubikey.nixos = {
      config,
      host,
      pkgs,
      lib,
      ...
    }: let
      owner = lib.head (lib.attrNames host.users);
      ssh = config.programs.ssh.package;
      inherit (config.programs.ssh) knownHosts;
      hostNames = hosts: lib.concatStringsSep "," (lib.concatMap (host: host.hostNames) hosts);

      # the stubs have no passphrase; the key itself is the guard
      loadKeys = pkgs.writeShellScript "ssh-agent-sk-load" ''
        shopt -s nullglob
        keys=()
        for k in "$HOME"/.ssh/id_*_sk_rk_*; do
          [[ $k == *.pub ]] || keys+=("$k")
        done
        (( ''${#keys[@]} )) || exit 0
        SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-sk.sock" ${ssh}/bin/ssh-add "''${keys[@]}"
      '';

      # a touch prints a line and ends auth; a miss jumps past it, says so and asks the password
      # pam_exec, not pam_echo: plain sudo runs pam silent and pam_echo then returns ignore
      touchCue = name: let
        inherit (config.security.pam.services.${name}.rules.auth) u2f;
        echo = order: control: text: {
          inherit order control;
          modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
          args = ["quiet" "stdout" "${pkgs.coreutils}/bin/echo" text];
        };
      in {
        u2f.enable = true;
        rules.auth = {
          u2f.control = lib.mkForce "[success=ok default=1]";
          touch-ok = echo (u2f.order + 1) "[success=done default=ignore]" "✓ touch accepted";
          touch-missed = echo (u2f.order + 2) "[default=ignore]" "✗ no touch, password instead";
        };
      };
    in {
      environment.systemPackages = [
        pkgs.yubikey-manager
        pkgs.libfido2
        pkgs.pam_u2f
      ];

      # one origin, so a key registered once works on both hosts
      security.pam.u2f.settings = {
        origin = "pam://aneesh";
        authfile = config.sops.secrets."u2f-keys".path;
        cue = true;
      };

      sops.secrets =
        {
          # shatterlock runs pam as the user
          "u2f-keys" = {
            sopsFile = config.secrets'.shared;
            mode = "0444";
          };
        }
        // lib.mapAttrs' (name: _:
          lib.nameValuePair "ssh-sk/${name}" {
            sopsFile = config.secrets'.shared;
            inherit owner;
          })
        den.lib.securityKeys;

      # where ssh-keygen -K puts them; linked at login, sops runs before ~ is mounted
      systemd.user.tmpfiles.users.${owner}.rules =
        ["d %h/.ssh 0700 - - -"]
        ++ lib.concatLists (lib.mapAttrsToList (name: key: let
            stub = "%h/.ssh/id_ed25519_sk_rk_${name}";
          in [
            "L+ ${stub} - - - - ${config.sops.secrets."ssh-sk/${name}".path}"
            "L+ ${stub}.pub - - - - ${pkgs.writeText "${name}.pub" "${key.ssh}\n"}"
          ])
          den.lib.securityKeys);

      # login stays password only: the keyring unlocks from it
      security.pam.services = {
        sudo = touchCue "sudo";
        sudo-i = touchCue "sudo-i";
        # run0 asks through polkit too
        polkit-1 = touchCue "polkit-1";
        # shatterlock runs it beside the password field, retrying until a touch
        shatterlock-key = {
          u2f.enable = true;
          unixAuth = false;
          # no authpending file: yubikey-touch-detector would notify behind the lock all night
          rules.auth.u2f.settings.authpending_file = "";
        };
      };

      # polkit's sandboxed helper sees no devices, so no key without hidraw
      systemd.services."polkit-agent-helper@".serviceConfig = {
        PrivateDevices = false;
        DeviceAllow = ["char-hidraw rw"];
      };

      # a notification while a key blinks for a touch
      programs.yubikey-touch-detector.enable = true;

      # only the security keys, forwarded so sudo on the servers takes a touch
      environment.variables.SSH_SK_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-sk.sock";
      systemd.user.services.ssh-agent-sk = {
        description = "ssh-agent with only the security keys";
        wantedBy = ["default.target"];
        serviceConfig = {
          Type = "forking";
          ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/ssh-sk.sock";
          ExecStart = "${ssh}/bin/ssh-agent -a %t/ssh-sk.sock";
          ExecStartPost = "-${loadKeys}";
          StandardOutput = "null";
          SuccessExitStatus = "0 2";
        };
      };
      programs.ssh.extraConfig = ''
        Match originalhost ${hostNames [knownHosts.homelab knownHosts.vps]} user aneesh
          ForwardAgent ''${SSH_SK_AUTH_SOCK}
        # root here takes only the security keys
        Match originalhost ${hostNames (lib.attrValues knownHosts)} user root
          IdentityAgent ''${SSH_SK_AUTH_SOCK}
      '';
    };

    provides.trust-homelab.nixos = {
      security.pki.certificates = [
        ''
          -----BEGIN CERTIFICATE-----
          MIIBozCCAUmgAwIBAgIQLYcNA4+cu47ty15Su/r6ZTAKBggqhkjOPQQDAjAwMS4w
          LAYDVQQDEyVDYWRkeSBMb2NhbCBBdXRob3JpdHkgLSAyMDI2IEVDQyBSb290MB4X
          DTI2MDEyMjAwMTcwMloXDTM1MTIwMTAwMTcwMlowMDEuMCwGA1UEAxMlQ2FkZHkg
          TG9jYWwgQXV0aG9yaXR5IC0gMjAyNiBFQ0MgUm9vdDBZMBMGByqGSM49AgEGCCqG
          SM49AwEHA0IABIgVvnJLhkz68mYxlO19+6L459rbV0zvE0Oxlac8kmzratZJMzMh
          1xp0JmOrmtMI/O6Y20LX7iX4v5Zb4pt/cOSjRTBDMA4GA1UdDwEB/wQEAwIBBjAS
          BgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBTnEZhrf7lP7dHy9liMqzFrcfZd
          aDAKBggqhkjOPQQDAgNIADBFAiBoSwq7Yhw2HdRAWT/f5XtFZBv77B/3enxO7hY+
          XPvShgIhAO0D+X1r+UELLKTSRInxomzNUz4FS/+LUibiYlAKhN5n
          -----END CERTIFICATE-----
        ''
      ];
    };
  };
}

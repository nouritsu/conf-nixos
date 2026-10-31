{
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
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.login.enableGnomeKeyring = true;

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
      pkgs,
      ...
    }: let
      ssh = config.programs.ssh.package;

      # stubs from ssh-keygen -K, no passphrase; the key itself is the guard
      loadKeys = pkgs.writeShellScript "ssh-agent-sk-load" ''
        shopt -s nullglob
        keys=()
        for k in "$HOME"/.ssh/id_*_sk_rk_*; do
          [[ $k == *.pub ]] || keys+=("$k")
        done
        (( ''${#keys[@]} )) || exit 0
        SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-sk.sock" ${ssh}/bin/ssh-add "''${keys[@]}"
      '';
    in {
      environment.systemPackages = [
        pkgs.yubikey-manager
        pkgs.libfido2
        pkgs.pam_u2f
      ];

      # one origin, so a key registered once works on both hosts
      security.pam.u2f.settings = {
        origin = "pam://aneesh";
        authfile = ./u2f-keys;
        cue = true;
      };

      # greetd and login stay password only: the keyring unlocks from it
      security.pam.services = {
        sudo.u2f.enable = true;
        sudo-i.u2f.enable = true;
        # run0 asks through polkit too
        polkit-1.u2f.enable = true;
        # shatterlock runs it beside the password field, retrying until a touch
        shatterlock-key = {
          u2f.enable = true;
          unixAuth = false;
        };
      };
      shatterlock'.settings.lock.fingerprintService = "shatterlock-key";

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
        Match originalhost homelab,192.168.178.128,nouritsu.com user aneesh
          ForwardAgent ''${SSH_SK_AUTH_SOCK}
        # root here takes only the security keys
        Match originalhost pc,laptop,pc.local,laptop.local user root
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

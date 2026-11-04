{
  den,
  lib,
  ...
}: {
  den.aspects.ssh = let
    inherit (den.hosts.x86_64-linux) pc laptop;

    securityKeys = lib.mapAttrsToList (_: key: key.ssh) den.lib.securityKeys;
  in {
    nixos = {
      config,
      lib,
      ...
    }: {
      services.openssh = {
        enable = true;
        openFirewall = true;
        allowSFTP = true;
        # only the keys declared here, none added to ~/.ssh/authorized_keys
        authorizedKeysInHomedir = false;
        settings = {
          PasswordAuthentication = false;
          PubkeyAuthentication = true;
          PermitRootLogin = "prohibit-password";
          # logs the fingerprint of the key each login used
          LogLevel = "VERBOSE";
        };
        # root only with a security key and a touch, whatever its authorized_keys holds
        extraConfig = ''
          Match User root
            PubkeyAcceptedAlgorithms sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com
            PubkeyAuthOptions touch-required
          Match All
        '';
      };

      # home wi-fi and the tailnets are never banned
      services.fail2ban = {
        enable = true;
        ignoreIP = ["192.168.178.0/24" "100.64.0.0/10" "fd7a:115c:a1e0::/48"];
        bantime-increment = {
          enable = true;
          maxtime = "1w";
        };
      };

      # a changed host key is refused, not trusted on first use
      programs.ssh.knownHosts = {
        pc = {
          extraHostNames = ["pc.local"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI6n+UTnGyxFYxXVzIgWcuAsCuJECEtLSB8P4JcA5LW";
        };
        laptop = {
          extraHostNames = ["laptop.local"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICToP5L7BQWCQwDeejymjky0PiHz/TXWHbWxTyDE5vv6";
        };
        homelab = {
          extraHostNames = ["192.168.178.128"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxcM2mWM7E1eY0j8tWmifyx3VkvhM2irkGx3e3t97W/";
        };
        vps = {
          hostNames = ["nouritsu.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGfueKWTRGtY20+RWrRPJHPvo1CmKOd0T/YJ9nbOXk4Q";
        };
      };
      # the machines tv and yazi offer
      environment.etc."ssh/hosts".text = lib.concatLines (lib.mapAttrsToList (_: host: lib.head host.hostNames) config.programs.ssh.knownHosts);

      # a kept connection is logged in already, so a root@ login skips its touch;
      # local root (nix-daemon) has no runtime dir for the socket
      programs.ssh.extraConfig = ''
        Match !localuser root
          ControlMaster auto
          ControlPath /run/user/%i/ssh-%C
          ControlPersist 10m
        Match sessiontype shell
          VisualHostKey yes
      '';
    };

    # a touch logs in from anywhere, the phone included over nfc
    user.openssh.authorizedKeys.keys = securityKeys;

    from-pc = {
      user.openssh.authorizedKeys.keys = [pc.sshKey];
      nixos.users.users.root.openssh.authorizedKeys.keys = securityKeys;
    };

    # not root: only the pc logs in as root
    from-laptop.user.openssh.authorizedKeys.keys = [laptop.sshKey];
  };
}

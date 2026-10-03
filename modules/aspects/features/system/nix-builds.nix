{
  den.aspects.nix = let
    user = "nix-ssh";
  in {
    builds-on-laptop.nixos = {config, ...}: {
      sops.secrets."nix-builder-key" = {};

      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = "lenovo";
          protocol = "ssh-ng";
          sshUser = user;
          sshKey = config.sops.secrets."nix-builder-key".path;

          # aarch64 through binfmt
          systems = ["x86_64-linux" "i686-linux" "aarch64-linux"];
          supportedFeatures = ["benchmark" "big-parallel" "kvm" "nixos-test"];

          # 15 GiB of RAM
          maxJobs = 2;
        }
      ];

      # nix-daemon connects as root, so the host key and ssh options go here
      programs.ssh.knownHosts.lenovo.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICToP5L7BQWCQwDeejymjky0PiHz/TXWHbWxTyDE5vv6";
      programs.ssh.extraConfig = ''
        Host lenovo
          Compression yes
          ConnectTimeout 3
      '';
    };

    builds-from-pc.nixos = {
      config,
      pkgs,
      ...
    }: let
      # like nix.sshServe, but refuses while on battery
      serve = pkgs.writeShellScript "nix-builds-from-pc" ''
        if ! ${config.systemd.package}/bin/systemd-ac-power; then
          echo "lenovo is on battery; not taking builds" >&2
          exit 1
        fi
        exec ${config.nix.package.out}/bin/nix-daemon --stdio
      '';
    in {
      users.users.${user} = {
        isSystemUser = true;
        group = user;
        # sshd runs ForceCommand through the login shell
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiobx5pv1m0BYAw3/N/7MCpSQlCrTbS20m2XUsarry3 nix-builder@pc"
        ];
      };
      users.groups.${user} = {};
      nix.settings.trusted-users = [user];

      services.openssh.extraConfig = ''
        Match User ${user}
          AllowAgentForwarding no
          AllowTcpForwarding no
          PermitTTY no
          PermitTunnel no
          X11Forwarding no
          ForceCommand ${serve}
        Match All
      '';
    };
  };
}

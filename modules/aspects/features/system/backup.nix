{
  den.aspects.backup = let
    user = "homelab-backup";
    repo = "/backup/homelab";
  in {
    from-homelab.nixos = {
      config,
      pkgs,
      ...
    }: {
      users.users.${user} = {
        isSystemUser = true;
        group = user;
        # sshd runs ForceCommand through the login shell
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILOXyy6RqOate/8Bm0xCMK7+/IvJusrPcAWEL/bO6jjo homelab-backup@homelab"
        ];
      };
      users.groups.${user} = {};

      systemd.tmpfiles.rules = [
        "d /backup 0755 root root -"
        "d ${repo} 0700 ${user} ${user} -"
      ];

      # ignores the command line the pi sends
      services.openssh.extraConfig = ''
        Match User ${user}
          AllowAgentForwarding no
          AllowTcpForwarding no
          PermitTTY no
          PermitTunnel no
          X11Forwarding no
          ForceCommand ${pkgs.rclone}/bin/rclone serve restic --stdio --append-only ${repo}
        Match All
      '';

      sops.secrets."homelab-restic-password".owner = user;

      # the pi can't delete, so pruning happens here
      services.restic.backups.homelab-prune = {
        repository = repo;
        inherit user;
        passwordFile = config.sops.secrets."homelab-restic-password".path;
        paths = [];
        initialize = false;
        pruneOpts = ["--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6"];
        runCheck = true;
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
  };
}

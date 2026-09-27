{
  # pc hands its compiles to the laptop whenever the laptop can take them. The
  # laptop is the faster machine -- 7-Zip rates it 32,904 MIPS to pc's 22,035 --
  # and what pc still compiles after an update is CPU-bound: the NVIDIA module,
  # dms-shell, xwayland-satellite, any cachyos kernel lantian has not built yet.
  # The other direction buys nothing: the laptop already gets pc's builds
  # through nix.from-pc.
  den.aspects.nix = let
    user = "nix-ssh";
  in {
    builds-on-laptop.nixos = {config, ...}: {
      # The public half is the one key builds-from-pc accepts.
      sops.secrets."nix-builder-key" = {};

      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = "lenovo";
          protocol = "ssh-ng";
          sshUser = user;
          sshKey = config.sops.secrets."nix-builder-key".path;

          # everything the laptop builds for itself, aarch64 through binfmt
          systems = ["x86_64-linux" "i686-linux" "aarch64-linux"];
          supportedFeatures = ["benchmark" "big-parallel" "kvm" "nixos-test"];

          # 15 GiB of RAM; two builds at once is what it holds comfortably
          maxJobs = 2;
        }
      ];

      # The daemon connects as root through plain ssh, so its host key and
      # client options live here. pc ships the build inputs itself
      # (builders-use-substitutes stays off): compressed, the LAN outruns the
      # laptop's own internet. The timeout bounds what a sleeping or absent
      # laptop costs before the build falls back to local.
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
      # nix.sshServe forces nix-daemon unconditionally; this declines while on
      # battery instead, and pc builds locally.
      serve = pkgs.writeShellScript "nix-builds-from-pc" ''
        if ! ${config.systemd.package}/bin/systemd-ac-power; then
          echo "lenovo is on battery; not taking builds" >&2
          exit 1
        fi
        exec ${config.nix.package.out}/bin/nix-daemon --stdio
      '';
    in {
      # Trusted, so pc's daemon can hand over whole derivations -- as much power
      # over this store as root, which pc already has over ssh.
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

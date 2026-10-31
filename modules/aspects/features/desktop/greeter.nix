{
  den.aspects.greeter.nixos = {
    config,
    host,
    self',
    pkgs,
    lib,
    ...
  }: let
    tuigreet = lib.getExe pkgs.tuigreet;
    niri = self'.packages.niri;
    sessions = "${niri}/share/wayland-sessions";
    owner = lib.head (lib.attrNames host.users);

    inherit (config.greeter') diskLoginKey;
    afterDisk = diskLoginKey != null;

    # where the initrd leaves diskLoginKey's key, only after a security key opened the disk
    loginKey = "/run/keyring-key/key";

    # the login password, encrypted to that key or to both security keys; per host, out of git
    sealed = "$HOME/.local/state/keyring-password.${
      if afterDisk
      then "enc"
      else "age"
    }";

    # once per host, and after a password change; no touch needed
    sealKeyring = pkgs.writeShellApplication {
      name = "seal-keyring";
      runtimeInputs = [pkgs.age pkgs.age-plugin-fido2-hmac pkgs.coreutils pkgs.openssl];
      text =
        ''
          umask 077
          mkdir -p "$(dirname "${sealed}")"
        ''
        + lib.optionalString afterDisk ''
          key=$(/run/wrappers/bin/sudo ${lib.getExe diskLoginKey})
        ''
        + ''
          read -rsp "login password: " pass
          echo
        ''
        + (
          if afterDisk
          then ''
            printf %s "$pass" | openssl enc -aes-256-cbc -pbkdf2 -pass fd:3 -out "${sealed}" 3<<< "$key"
          ''
          else ''
            printf %s "$pass" | age -R ${./keyring-recipients} -o "${sealed}"
          ''
        );
    };

    # the touch decrypts the password, proving the key and unlocking the keyring; after a disk
    # unlock by key, that touch already happened. Exiting instead hands over to tuigreet
    keyLogin = pkgs.writeShellApplication {
      name = "key-login";
      runtimeInputs = [pkgs.age pkgs.age-plugin-fido2-hmac pkgs.libfido2 pkgs.openssl];
      text =
        (
          if afterDisk
          then ''
            if [ ! -f ${loginKey} ]; then
              exit 0
            fi
            # one login per key unlock, whatever happens next
            pass=$(openssl enc -d -aes-256-cbc -pbkdf2 -pass file:${loginKey} -in "${sealed}" 2> /dev/null) || pass=
            rm -f ${loginKey}
            if [ -z "$pass" ]; then
              exit 0
            fi
          ''
          else ''
            if [ ! -f "${sealed}" ] || [ -z "$(fido2-token -L)" ]; then
              exit 0
            fi
            echo "Touch your security key"
            pass=$(age -d -j fido2-hmac "${sealed}" 2> /dev/null) || exit 0
          ''
        )
        + ''
          # pam started a locked daemon for this session; swap it for an unlocked one
          printf %s "$pass" | /run/wrappers/bin/gnome-keyring-daemon --replace --unlock --daemonize > /dev/null 2>&1
          unset pass
          exec ${niri}/bin/niri-session
        '';
    };
  in {
    imports = [
      {
        # prints, as root, the key the initrd leaves in /run/keyring-key/key after a security key opens the disk
        options.greeter'.diskLoginKey = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
        };
      }
    ];

    environment.systemPackages = [sealKeyring];

    # the initrd made it root's; key-login, as the owner, reads and removes it
    systemd.tmpfiles.rules = lib.optional afterDisk "Z ${dirOf loginKey} - ${owner} - - -";

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session --sessions ${sessions}";
          user = "greeter";
        };
        # once per boot, unauthenticated: key-login is the check
        initial_session = {
          command = lib.getExe keyLogin;
          user = owner;
        };
      };
    };
  };
}

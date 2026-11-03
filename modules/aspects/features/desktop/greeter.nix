{
  den.aspects.greeter.nixos = {
    config,
    host,
    self',
    pkgs,
    lib,
    ...
  }: let
    owner = lib.head (lib.attrNames host.users);

    inherit (config.greeter') diskLoginKey;
    afterDisk = diskLoginKey != null;

    # where the initrd leaves diskLoginKey's key, only after a security key opened the disk
    loginKey = "/run/keyring-key/key";

    # the login password: .age to both security keys, .enc to diskLoginKey's key; per host, out of git
    sealed = "${config.users.users.${owner}.home}/.local/state/keyring-password";

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
          printf %s "$pass" | age -R ${./keyring-recipients} -o "${sealed}.age"
        ''
        + lib.optionalString afterDisk ''
          printf %s "$pass" | openssl enc -aes-256-cbc -pbkdf2 -pass fd:3 -out "${sealed}.enc" 3<<< "$key"
        '';
    };

    # pam_systemd_loadkey's name for it in the greeter's session keyring
    keyName = "greeter-key-login";

    # pam_exec runs it as root with the typed password on stdin. Only an empty one asks for the key:
    # the touch decrypts the real password, so pam_unix still checks it and the keyring unlocks from it.
    # After a disk unlock by key, that touch already happened
    keyLogin = pkgs.writeShellApplication {
      name = "key-login";
      runtimeInputs = [pkgs.age pkgs.age-plugin-fido2-hmac pkgs.coreutils pkgs.libfido2 pkgs.openssl pkgs.keyutils];
      # pam_exec passes no PATH
      inheritPath = false;
      text =
        ''
          if [ "$PAM_USER" != "${owner}" ]; then
            exit 1
          fi
          pass=
        ''
        + lib.optionalString afterDisk ''
          # one login per key unlock, whatever happens next
          if [ -f ${loginKey} ]; then
            pass=$(openssl enc -d -aes-256-cbc -pbkdf2 -pass file:${loginKey} -in "${sealed}.enc" 2> /dev/null) || pass=
            rm -f ${loginKey}
          fi
        ''
        + ''
          if IFS= read -r -n 1 _; then
            exit 1
          fi
          if [ -z "$pass" ]; then
            if [ ! -f "${sealed}.age" ] || [ -z "$(fido2-token -L)" ]; then
              exit 1
            fi
            pass=$(age -d -j fido2-hmac "${sealed}.age" 2> /dev/null) || exit 1
          fi
          id=$(printf %s "$pass" | keyctl padd user ${keyName} @s)
          unset pass
          # the user's session inherits this keyring; possessing it mustn't be enough to read the password
          keyctl setperm "$id" 0x003f0000
          keyctl timeout "$id" 10
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

    services.displayManager.lemurs = {
      enable = true;
      package = self'.packages.lemurs;
      settings = let
        # the console palette is catppuccin's; magenta is its pink, the nearest to mauve
        focused = {
          title_color_focused = "magenta";
          content_color_focused = "magenta";
          border_color_focused = "magenta";
        };
      in {
        environment_switcher = {
          mover_color_focused = "magenta";
          selected_color_focused = "magenta";
        };
        username_field.style = focused;
        password_field.style = focused // {title = "Password, or Enter for key";};
      };
    };

    # before anything prompts: key-login asks for the password itself, and on success
    # pam_systemd_loadkey makes the unsealed one the password for everything after
    security.pam.services.lemurs.rules.auth = let
      inherit (config.security.pam.services.lemurs.rules.auth.unix-early) order;
    in {
      key-login = {
        order = order - 2;
        control = "[success=ok default=1]";
        modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
        args = ["quiet" "quiet_log" "expose_authtok" (lib.getExe keyLogin)];
      };
      key-password = {
        order = order - 1;
        control = "optional";
        modulePath = "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";
        args = ["keyname=${keyName}"];
      };
    };
  };
}

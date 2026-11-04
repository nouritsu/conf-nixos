{den, ...}: {
  den.aspects.greeter.nixos = {
    config,
    host,
    self',
    pkgs,
    lib,
    ...
  }: let
    owner = lib.head (lib.attrNames host.users);

    inherit (config.greeter') diskLoginKey diskLoginKeyFile;
    afterDisk = diskLoginKey != null;

    # the login password: .age to both security keys, .enc to diskLoginKey's key; per host, out of git
    sealed = "${config.users.users.${owner}.home}/.local/state/keyring-password";
    enc = "openssl enc -aes-256-cbc -pbkdf2";
    recipients = pkgs.writeText "keyring-recipients" (lib.concatLines (lib.mapAttrsToList (_: key: key.age) den.lib.securityKeys));

    # once per host, and after a password change; no touch needed
    sealKeyring = pkgs.writeShellApplication {
      name = "seal-keyring";
      runtimeInputs = [pkgs.age pkgs.age-plugin-fido2-hmac pkgs.coreutils pkgs.openssl];
      text = ''
        umask 077
        mkdir -p "$(dirname "${sealed}")"
        ${lib.optionalString afterDisk "key=$(/run/wrappers/bin/sudo ${lib.getExe diskLoginKey})"}
        read -rsp "login password: " pass
        echo
        printf %s "$pass" | age -R ${recipients} -o "${sealed}.age"
        ${lib.optionalString afterDisk ''printf %s "$pass" | ${enc} -pass fd:3 -out "${sealed}.enc" 3<<< "$key"''}
      '';
    };

    # pam_systemd_loadkey's name for it in the greeter's session keyring
    keyName = "greeter-key-login";

    # pam_exec runs it as root, typed password on stdin; only an empty one asks for a touch,
    # which unseals the real one so pam_unix and the keyring still get it
    keyLogin = pkgs.writeShellApplication {
      name = "key-login";
      runtimeInputs = [pkgs.age pkgs.age-plugin-fido2-hmac pkgs.coreutils pkgs.libfido2 pkgs.openssl pkgs.keyutils];
      # pam_exec passes no PATH
      inheritPath = false;
      text = ''
        if [ "$PAM_USER" != "${owner}" ]; then
          exit 1
        fi
        pass=
        ${lib.optionalString afterDisk ''
          # the disk's key unlock was the touch; one login per unlock, whatever happens next
          if [ -f ${diskLoginKeyFile} ]; then
            pass=$(${enc} -d -pass file:${diskLoginKeyFile} -in "${sealed}.enc" 2> /dev/null) || pass=
            rm -f ${diskLoginKeyFile}
          fi
        ''}
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
        options.greeter' = {
          # prints, as root, what the initrd leaves in diskLoginKeyFile
          diskLoginKey = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = null;
          };
          # only there after a security key opened the disk
          diskLoginKeyFile = lib.mkOption {
            type = lib.types.str;
            default = "/run/keyring-key/key";
            readOnly = true;
          };
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
        password_field.style = focused // {title = "Password (empty: security key)";};
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

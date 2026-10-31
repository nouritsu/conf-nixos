{
  den.aspects.greeter.nixos = {
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

    # the login password, encrypted to both security keys; per host, out of git
    sealed = "$HOME/.local/state/keyring-password.age";

    # once per host, and after a password change; no touch needed
    sealKeyring = pkgs.writeShellApplication {
      name = "seal-keyring";
      runtimeInputs = [pkgs.age pkgs.age-plugin-fido2-hmac pkgs.coreutils];
      text = ''
        umask 077
        mkdir -p "$(dirname "${sealed}")"
        read -rsp "login password: " pass
        echo
        printf %s "$pass" | age -R ${./keyring-recipients} -o "${sealed}"
      '';
    };

    # a touch decrypts the password, proving the key and unlocking the keyring;
    # exiting instead hands over to tuigreet
    keyLogin = pkgs.writeShellApplication {
      name = "key-login";
      runtimeInputs = [pkgs.age pkgs.age-plugin-fido2-hmac pkgs.libfido2];
      text = ''
        if [ ! -f "${sealed}" ] || [ -z "$(fido2-token -L)" ]; then
          exit 0
        fi
        echo "Touch your security key"
        pass=$(age -d -j fido2-hmac "${sealed}" 2> /dev/null) || exit 0
        # pam started a locked daemon for this session; swap it for an unlocked one
        printf %s "$pass" | /run/wrappers/bin/gnome-keyring-daemon --replace --unlock --daemonize > /dev/null 2>&1
        unset pass
        exec ${niri}/bin/niri-session
      '';
    };
  in {
    environment.systemPackages = [sealKeyring];

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

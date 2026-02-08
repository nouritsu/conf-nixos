{
  config,
  pkgs,
  ...
}: let
  get-nixos-ssh-keys = "${pkgs.openssh}/libexec/nixos-ssh-authorized-keys";

  get-sops-ssh-key = pkgs.writeShellScript "get-sops-ssh-key" ''
    set -eu
    KEY_FILE="${config.sops.secrets."ssh-public-key".path}"
    REQUESTED_USER="$1"
    CONFIGURED_USER="${config.my.user.alias}"

    if [ -f "$KEY_FILE" ] && [ "$REQUESTED_USER" = "$CONFIGURED_USER" ]; then
      cat "$KEY_FILE"
    fi
  '';

  get-ssh-keys = pkgs.writeShellScript "combined-ssh-keys-command" ''
    ${get-nixos-ssh-keys} "$1"
    ${get-sops-ssh-key} "$1"
  '';
in {
  services.openssh = {
    enable = true;
    ports = [18187];
    openFirewall = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
    };

    authorizedKeysCommand = "${get-ssh-keys}";
    authorizedKeysCommandUser = "root";
  };
}

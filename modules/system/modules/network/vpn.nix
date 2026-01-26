{
  pkgs,
  config,
  ...
}: let
  mullvad = "${config.services.mullvad-vpn.package}/bin/mullvad";
  account-number-file = config.sops.secrets.mullvad-account-number.path;
in {
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  services.resolved.enable = true;

  systemd.services.mullvad-daemon = {
    after = ["sops-nix.service"];
    wants = ["sops-nix.service"];

    postStart = ''
      while ! ${mullvad} status &>/dev/null; do sleep 1; done

      if ${mullvad} account get 2>&1 | grep -q "Not logged in"; then
        ${mullvad} account login "$(cat ${account-number-file})"
      fi

      ${mullvad} auto-connect set on
    '';
  };
}

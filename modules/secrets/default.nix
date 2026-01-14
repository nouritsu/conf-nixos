{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = [
    pkgs.sops
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/${config.my.user.alias}/.config/sops/age/keys.txt";

  # Secrets
  sops.secrets."ssh-public-key" = {};
  sops.secrets."mullvad-account-number" = {};
}

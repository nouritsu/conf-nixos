{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/${config.my.user.alias}/.config/sops/age/keys.txt";

  # Secrets
  sops.secrets."ssh-public-key" = {};
}

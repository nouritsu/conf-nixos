{
  inputs,
  osConfig,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${osConfig.my.user.alias}/.config/sops/age/keys.txt";

  # Secrets
  sops.secrets."filebot-license" = {};
}

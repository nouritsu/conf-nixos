{
  flake.nixosModules.secrets = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    environment.systemPackages = [
      pkgs.sops
    ];

    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
    };

    sops.age.keyFile = "/home/aneesh/.config/sops/age/keys.txt";

    sops.secrets."home-assistant-token" = {
      owner = "aneesh";
    };
  };
}

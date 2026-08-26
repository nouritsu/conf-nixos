{inputs, ...}: {
  den.aspects.secrets.nixos = {pkgs, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    environment.systemPackages = [pkgs.sops];

    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/aneesh/.config/sops/age/keys.txt";
    };

    sops.secrets."home-assistant-token" = {
      owner = "aneesh";
    };
  };
}

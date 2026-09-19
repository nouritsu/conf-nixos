{
  inputs,
  lib,
  ...
}: {
  den.aspects.secrets = {host, ...}: let
    # The age identity lives in the account's home, and that same account is
    # what reads the decrypted secrets. Hosts here carry a single one.
    owner = lib.head (lib.attrNames host.users);
  in {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      imports = [inputs.sops-nix.nixosModules.sops];

      environment.systemPackages = [pkgs.sops];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "${config.users.users.${owner}.home}/.config/sops/age/keys.txt";
      };

      sops.secrets."home-assistant-token" = {
        inherit owner;
      };
    };
  };
}

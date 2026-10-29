{
  inputs,
  lib,
  ...
}: {
  den.aspects.secrets = {host, ...}: let
    owner = lib.head (lib.attrNames host.users);
  in {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      imports = [inputs.sops-nix.nixosModules.sops];

      environment.systemPackages = [pkgs.sops];

      # each host aspect sets sops.defaultSopsFile to its own secrets.yaml;
      # secrets both hosts read name ./shared.yaml as their sopsFile
      sops = {
        defaultSopsFormat = "yaml";
        age.keyFile = "${config.users.users.${owner}.home}/.config/sops/age/keys.txt";
      };

      # mutable users: only applied when the user is first created
      sops.secrets."${owner}/password" = {
        sopsFile = ./shared.yaml;
        neededForUsers = true;
      };
      users.users.${owner}.hashedPasswordFile = config.sops.secrets."${owner}/password".path;
    };
  };
}

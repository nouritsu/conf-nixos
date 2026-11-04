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
      imports = [
        inputs.sops-nix.nixosModules.sops
        {
          # what both hosts read; the rest is in each host aspect's sops.defaultSopsFile
          options.secrets'.shared = lib.mkOption {
            type = lib.types.path;
            default = ./shared.yaml;
            readOnly = true;
          };
        }
      ];

      environment.systemPackages = [pkgs.sops];

      sops = {
        defaultSopsFormat = "yaml";
        age.keyFile = "${config.users.users.${owner}.home}/.config/sops/age/keys.txt";
      };

      # mutable users: only applied when the user is first created
      sops.secrets."${owner}/password" = {
        sopsFile = config.secrets'.shared;
        neededForUsers = true;
      };
      users.users.${owner}.hashedPasswordFile = config.sops.secrets."${owner}/password".path;
    };
  };
}

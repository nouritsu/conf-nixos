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

      # editing decrypts with a touch: the plugin's magic identity in ~/.config/sops/age/keys.txt
      environment.systemPackages = [pkgs.sops pkgs.age-plugin-fido2-hmac];

      sops = {
        defaultSopsFormat = "yaml";
        # .sops.yaml's host recipients are these keys; a new host key needs sops updatekeys
        age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
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

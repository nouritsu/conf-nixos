{
  den,
  lib,
  ...
}: {
  # shared by the git and jujutsu wrappers
  flake.nixosModules.wgit-identity = {
    config,
    pkgs,
    ...
  }: {
    options = {
      # public ssh signing key per hostname
      signingKeys = lib.mkOption {type = lib.types.attrsOf lib.types.str;};
      allowedSigners = lib.mkOption {type = lib.types.package;};
    };

    config = {
      settings.user = {
        name = "Aneesh Bhave";
        email = "ab@nouritsu.com";
      };

      # each host signs with its ordinary ssh key, through its agent, so no touch
      signingKeys = lib.mapAttrs (_: host: host.sshKey) den.hosts.x86_64-linux;

      allowedSigners = pkgs.writeText "allowed-signers" (lib.concatMapStrings (key: "${config.settings.user.email} ${key}\n") (lib.attrValues config.signingKeys));
    };
  };
}

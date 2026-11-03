{lib, ...}: {
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
      signingKeys = {
        pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwVvRZ6cNb1mSXehYaqGtX5EkdSb9IqKzdsXPepddhY ab@nouritsu.com";
        laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaijmb2WJa4WkQNoKz05gibSe/4rIohMVJtY3KSM0va ab@nouritsu.com";
      };

      allowedSigners = pkgs.writeText "allowed-signers" (lib.concatMapStrings (key: "${config.settings.user.email} ${key}\n") (lib.attrValues config.signingKeys));
    };
  };
}

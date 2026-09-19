{
  den.aspects.ssh = {
    nixos = {
      services.openssh = {
        enable = true;
        openFirewall = true;
        allowSFTP = true;
        settings = {
          PasswordAuthentication = false;
          PubkeyAuthentication = true;
          PermitRootLogin = "prohibit-password";
        };
      };
    };

    # one key for both accounts, bound once so that stays true by construction:
    # root used to be reachable only by the pc-enc key, which meant two keys to
    # keep and the deploy account gated behind the one not used day to day
    from-pc = let
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwVvRZ6cNb1mSXehYaqGtX5EkdSb9IqKzdsXPepddhY aneesh@pc";
    in {
      # the `user` class lands on whichever account the host binds, so the
      # account name stays out of the feature; root is not that account.
      user.openssh.authorizedKeys.keys = [key];
      nixos.users.users.root.openssh.authorizedKeys.keys = [key];
    };

    # the lenovo laptop. aneesh only: root is the main key's alone.
    from-laptop.user.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaijmb2WJa4WkQNoKz05gibSe/4rIohMVJtY3KSM0va ab@nouritsu.com"
    ];
  };
}

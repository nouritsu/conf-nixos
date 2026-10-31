{
  den.aspects.ssh = let
    # resident on the two security keys
    securityKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMnLxjqSr4eW8FTR8/VqPheLwem+4Tyk/xvg7k/YwYxIAAAADXNzaDp5dWJpa2V5LWE= aneesh@yubikey-a"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILNf7NQHTL6oXtT5EfLaYSzUmr5ibxQnafPM4tKYxq/CAAAADXNzaDp5dWJpa2V5LWI= aneesh@yubikey-b"
    ];
  in {
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
        # root only with a security key and a touch, whatever its authorized_keys holds
        extraConfig = ''
          Match User root
            PubkeyAcceptedAlgorithms sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com
            PubkeyAuthOptions touch-required
          Match All
        '';
      };
    };

    from-pc = {
      user.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwVvRZ6cNb1mSXehYaqGtX5EkdSb9IqKzdsXPepddhY aneesh@pc"
      ];
      nixos.users.users.root.openssh.authorizedKeys.keys = securityKeys;
    };

    # not root: only the pc logs in as root
    from-laptop.user.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaijmb2WJa4WkQNoKz05gibSe/4rIohMVJtY3KSM0va ab@nouritsu.com"
    ];

    from-pixel.user.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHadN10Y/fBJFvDrH62DIIy8/jZN1mf5Mk6XOBkxdzoj aneesh@pixel"
    ];
  };
}

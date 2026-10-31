{
  den.aspects.ssh = let
    # resident on the two security keys
    securityKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMnLxjqSr4eW8FTR8/VqPheLwem+4Tyk/xvg7k/YwYxIAAAADXNzaDp5dWJpa2V5LWE= ab@nouritsu.com"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILNf7NQHTL6oXtT5EfLaYSzUmr5ibxQnafPM4tKYxq/CAAAADXNzaDp5dWJpa2V5LWI= ab@nouritsu.com"
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

      # a changed host key is refused, not trusted on first use
      programs.ssh.knownHosts = {
        pc = {
          extraHostNames = ["pc.local"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI6n+UTnGyxFYxXVzIgWcuAsCuJECEtLSB8P4JcA5LW";
        };
        laptop = {
          extraHostNames = ["laptop.local"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICToP5L7BQWCQwDeejymjky0PiHz/TXWHbWxTyDE5vv6";
        };
        homelab = {
          extraHostNames = ["192.168.178.128"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxcM2mWM7E1eY0j8tWmifyx3VkvhM2irkGx3e3t97W/";
        };
        vps = {
          hostNames = ["nouritsu.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGfueKWTRGtY20+RWrRPJHPvo1CmKOd0T/YJ9nbOXk4Q";
        };
      };
    };

    # a touch logs in from anywhere, the phone included over nfc
    user.openssh.authorizedKeys.keys = securityKeys;

    from-pc = {
      user.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwVvRZ6cNb1mSXehYaqGtX5EkdSb9IqKzdsXPepddhY ab@nouritsu.com"
      ];
      nixos.users.users.root.openssh.authorizedKeys.keys = securityKeys;
    };

    # not root: only the pc logs in as root
    from-laptop.user.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaijmb2WJa4WkQNoKz05gibSe/4rIohMVJtY3KSM0va ab@nouritsu.com"
    ];
  };
}

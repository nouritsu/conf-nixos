{
  flake.nixosModules = {
    ssh-base = {...}: {
      services.openssh = {
        enable = true;
        openFirewall = true;
        allowSFTP = true;
      };
    };

    ssh-harden = {...}: {
      services.openssh.settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
    };
  };
}

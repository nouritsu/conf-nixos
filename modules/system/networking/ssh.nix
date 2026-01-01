{
  services.openssh = {
    enable = true;
    ports = [18187];
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
    };
  };
}

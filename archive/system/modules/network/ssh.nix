{
  services.openssh = {
    enable = true;
    openFirewall = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
    };
  };
}

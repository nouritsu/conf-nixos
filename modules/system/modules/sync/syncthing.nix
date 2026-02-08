{
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    settings = {
      gui = {
        user = "admin";
        password = "$2y$05$E2gP6TBFqPr9Q3KK7aCFyeXoBhPntwbGbw6GRO9et1zr2LnPqaqAy";
        insecureSkipHostCheck = true;
      };

      devices = {
        "pc" = {
          id = "U5KKTMD-AXRIBAB-GVLY3JA-BHO42R7-HMBOBYF-SSWISQM-UQ2SCRC-3CPHXQI";
          autoAcceptFolders = true;
        };
      };

      folders = {
        "pc-cook-cli-base" = {
          path = "/var/lib/cook-cli";
          devices = ["pc"];
          type = "sendonly";
        };
      };
    };
  };

  systemd.services.syncthing.serviceConfig.SupplementaryGroups = ["users"];
}

{
  pkgs,
  config,
  ...
}: let
  license-file = config.sops.secrets.filebot-license.path;
  license-script = pkgs.writeShellApplication {
    name = "filebot-license-setup";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      mkdir -p "$HOME/.local/share/filebot/data"
      ln -sf "${license-file}" "$HOME/.local/share/filebot/data/.license"
    '';
  };
in {
  home.packages = [pkgs.filebot];

  systemd.user.services.filebot-license = {
    Unit = {
      description = "Set up FileBot license";
      after = ["sops-nix.service"];
      wants = ["sops-nix.service"];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${license-script}/bin/filebot-license-setup";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}

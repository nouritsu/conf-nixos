{
  pkgs,
  config,
  ...
}: let
  license-file = config.sops.secrets.filebot-license.path;

  license-script = pkgs.writeShellScript "filebot-license-script" ''
    mkdir -p "$HOME/.local/share/filebot/data"
    ln -sf "${license-file}" "$HOME/.local/share/filebot/data/.license"
  '';
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
      ExecStart = license-script;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}

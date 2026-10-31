{
  self,
  inputs,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.jujutsu = wrappers.wrappers.jujutsu.wrap [
      {
        inherit pkgs;
        package = pkgs.jujutsu;
      }

      self.nixosModules.wgit-identity

      ({config, ...}: let
        signers = pkgs.writeText "allowed-signers" (lib.concatMapStrings (key: "${config.settings.user.email} ${key}\n") (lib.attrValues config.signingKeys));
      in {
        settings = {
          ui = {
            pager = lib.getExe self'.packages.delta;
            diff-formatter = ":git";
          };

          merge-tools.delta.diff-expected-exit-codes = [0 1];

          # signed when pushed rather than on every snapshot
          signing = {
            behavior = "drop";
            backend = "ssh";
            backends.ssh.allowed-signers = "${signers}";
          };
          git.sign-on-push = true;
          "--scope" =
            lib.mapAttrsToList (host: key: {
              "--when".hostnames = [host];
              signing.key = key;
            })
            config.signingKeys;
        };
      })
    ];
  };
}

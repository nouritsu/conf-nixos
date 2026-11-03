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

      ({config, ...}: {
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
            backends.ssh.allowed-signers = "${config.allowedSigners}";
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

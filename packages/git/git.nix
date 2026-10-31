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
  }: let
    delta = lib.getExe self'.packages.delta;

    # without it https pushes to GitHub ask for credentials
    # "" clears any helper set in a lower scope
    gh = ["" "${lib.getExe pkgs.gh} auth git-credential"];

    # in every repo, so a stray secret or build output can't be committed
    ignore = pkgs.writeText "gitignore" ''
      .env
      .env.*
      !.env.example
      *.pem
      *.key
      id_rsa
      id_ecdsa
      id_ecdsa_sk
      id_ed25519
      id_ed25519_sk
      .direnv/
      result
      result-*
    '';
  in {
    packages.git = wrappers.wrappers.git.wrap [
      {
        inherit pkgs;
        package = pkgs.git;
      }

      self.nixosModules.wgit-identity

      ({config, ...}: let
        keys = config.signingKeys;
        signers = pkgs.writeText "allowed-signers" (lib.concatMapStrings (key: "${config.settings.user.email} ${key}\n") (lib.attrValues keys));
        signingKey = pkgs.writeShellScript "git-signing-key" ''
          case $(< /proc/sys/kernel/hostname) in
          ${lib.concatMapAttrsStringSep "\n" (host: key: "${host}) echo 'key::${key}' ;;") keys}
          esac
        '';
      in {
        settings = {
          credential."https://github.com".helper = gh;
          credential."https://gist.github.com".helper = gh;

          core.pager = delta;
          # status doesn't page by default
          pager.status = true;
          interactive.diffFilter = "${delta} --color-only";

          # glog: hash, age, refs, the subject cut at the edge, author on the right
          pretty.compact = "format:%C(auto)%h %C(blue)%<(13,trunc)%ar%C(auto)%d %C(reset)%<|(-14,trunc)%s %C(dim)%<(12,trunc)%an%C(reset)";

          push.autoSetupRemote = true;
          pull.rebase = true;
          fetch.prune = true;

          diff.algorithm = "histogram";
          diff.colorMoved = "default";
          merge.conflictStyle = "zdiff3";

          branch.sort = "-committerdate";
          tag.sort = "version:refname";
          commit.verbose = true;

          transfer.fsckObjects = true;
          core.excludesFile = "${ignore}";

          core.untrackedCache = true;
          fetch.writeCommitGraph = true;

          # github marks these verified once each key is added there as a signing key
          gpg.format = "ssh";
          gpg.ssh.defaultKeyCommand = "${signingKey}";
          gpg.ssh.allowedSignersFile = "${signers}";
          commit.gpgSign = true;
          tag.gpgSign = true;
        };
      })
    ];
  };
}

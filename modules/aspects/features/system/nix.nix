{
  inputs,
  lib,
  ...
}: {
  den.aspects.nix = {host, ...}: let
    # nh wants an absolute path to the flake, which only exists relative to an
    # account. Every host here carries a single one; its home directory is set
    # by den.batteries.define-user.
    primary = lib.head (lib.attrNames host.users);
  in {
    nixos = {config, ...}: {
      imports = [
        inputs.nix-index-database.nixosModules.default
      ];

      programs.nix-ld.enable = true;
      programs.nix-index-database.comma.enable = true;

      programs.nh = {
        enable = true;
        flake = "${config.users.users.${primary}.home}/.config/nixos";

        clean.enable = true;
        clean.extraArgs = "--keep 5 --keep-since 7d";
      };

      programs.fish.shellAliases.conf = "$EDITOR $NH_FLAKE";
      programs.fish.shellAbbrs = {
        nhrb = "nh os boot";
        nhrs = "nh os switch";
        nhrt = "nh os test";
        nhca = "nh clean all";
        nhs = "nh search";
      };

      nix.settings.trusted-users = ["root" "@wheel"];

      # Determinate's unmanaged /etc/nix/nix.conf supplied these; the repo owns
      # them now. experimental-features especially: nix.custom.conf has always
      # written it empty, so without this line nothing that speaks flakes --
      # nh included -- can run.
      nix.settings.experimental-features = ["nix-command" "flakes"];

      # Parity with what determinate-nixd wrote. Lets derivations that opt out
      # of substitution still come from a cache.
      nix.settings.always-allow-substitutes = true;

      # The system registry already pins `nixpkgs` to this flake's own nixpkgs
      # store path -- nixpkgs.flake.setFlakeRegistry defaults true under
      # lib.nixosSystem, and determinate was the only thing overriding it with a
      # FlakeHub tarball. A path entry carries store context, so registry.json
      # gains a reference and the tree stops being collected by nh clean; a URL
      # string carries none, which is why the pinned nixpkgs was refetched on
      # every clean.
      #
      # The *global* registry is then pure cost: a channels.nixos.org fetch,
      # re-checked every tarball-ttl, on every `nix shell` / `nix run`. Empty
      # disables it; use-registries stays on, so /etc/nix/registry.json still
      # resolves `nixpkgs`.
      nix.settings.flake-registry = "";

      # Channels are dead weight on a flake system, and the root channel profile
      # was still shadowing <nixpkgs> with a Dec-2025 tree. Off, nix.nixPath
      # collapses to `nixpkgs=flake:nixpkgs`, which routes through the registry
      # entry above and so back to this flake's pinned nixpkgs.
      nix.channel.enable = false;

      # TODO: move to per app
      nix.settings.extra-substituters = [
        "https://attic.xuyh0120.win/lantian"
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
        "https://yazi.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
    };
  };
}

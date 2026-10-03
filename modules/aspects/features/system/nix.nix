{
  inputs,
  lib,
  ...
}: {
  den.aspects.nix = {host, ...}: let
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
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nix.settings.always-allow-substitutes = true;

      # no global registry; /etc/nix/registry.json still has nixpkgs
      nix.settings.flake-registry = "";
      nix.channel.enable = false;

      # TODO: move to per app
      nix.settings.extra-substituters = [
        "https://attic.xuyh0120.win/lantian"
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
        "https://yazi.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
    };
  };
}

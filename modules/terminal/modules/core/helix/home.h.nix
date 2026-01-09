{
  config,
  inputs,
  lib,
  osConfig,
  ...
}: let
  helix-pkg = inputs.helix.packages.${osConfig.my.system.arch}.default;
  hx = lib.getExe' helix-pkg "hx";
  cfg = config.my.helix;
in {
  imports = [
    ./mod.h.nix
    ./mod/extra.h.nix
    ./mod/general.h.nix
    ./mod/lsp.h.nix
    ./mod/statusline.h.nix

    ./mod/nav/buffer.h.nix
    ./mod/nav/git.h.nix
    ./mod/nav/files.h.nix
    ./mod/nav/lsp.h.nix
    ./mod/nav/core.h.nix
    ./mod/nav/easymotion.h.nix

    ./mod/languages/nix.h.nix
    ./mod/languages/c.h.nix
    ./mod/languages/python.h.nix
    ./mod/languages/rust.h.nix
  ];

  programs.helix = {
    enable = true;
    package = helix-pkg;
    defaultEditor = true;

    extraConfig =
      /*
      toml
      */
      ''
        [keys.normal.g]
        ${cfg.binds_g}

        [keys.select.g]
        ${cfg.binds_g}

        [keys.normal.space]
        ${cfg.binds_space}

        [keys.select.space]
        ${cfg.binds_space}
      '';
  };

  home.shellAliases = rec {
    helix = "${hx}";
    vi = helix;
    vim = helix;
    nvim = helix;
  };
}

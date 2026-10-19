{
  flake.nixosModules.whelix-lsp-nix = {
    lib,
    pkgs,
    ...
  }: let
    nixd = lib.getExe pkgs.nixd;
    nil = lib.getExe pkgs.nil;
    alejandra = lib.getExe pkgs.alejandra;

    # option and package completion from this host's config
    host = ''
      let
        flake = builtins.getFlake (builtins.getEnv "NH_FLAKE");
        name = builtins.replaceStrings ["\n"] [""] (builtins.readFile /etc/hostname);
      in
        flake.nixosConfigurations.''${name}
    '';
  in {
    languages.language-server = {
      nixd = {
        command = nixd;
        config.nixd.nixpkgs.expr = "(${host}).pkgs";
        config.nixd.options = {
          nixos.expr = "(${host}).options";
        };
      };
      nil.command = nil;
    };

    languages.language = [
      {
        name = "nix";
        scope = "source.nix";
        injection-regex = "nix";
        file-types = ["nix"];
        language-servers = ["nixd" "nil"];

        formatter.command = alejandra;
        auto-format = true;

        comment-token = "#";
        block-comment-tokens = {
          start = "/*";
          end = "*/";
        };

        indent = {
          tab-width = 2;
          unit = "  ";
        };
      }
    ];
  };
}

{
  flake.nixosModules.whelix-lsp-bash = {
    lib,
    pkgs,
    ...
  }: let
    bash-language-server = lib.getExe pkgs.bash-language-server;
    shfmt = lib.getExe pkgs.shfmt;
  in {
    # shellcheck is already on its PATH
    languages.language-server.bash-language-server = {
      command = bash-language-server;
      config.bashIde.shfmt.path = shfmt;
    };

    languages.language = [
      {
        name = "bash";
        language-servers = ["bash-language-server" "scls"];
        auto-format = true;
      }
    ];
  };
}

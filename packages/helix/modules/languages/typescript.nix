{
  flake.nixosModules.whelix-lsp-typescript = {
    lib,
    pkgs,
    onDemand,
    ...
  }: {
    languages.language-server = {
      typescript-language-server.command = lib.getExe pkgs.typescript-language-server;
      svelteserver.command = onDemand "svelte-language-server" "svelteserver";
    };

    languages.language =
      map (name: {
        inherit name;
        language-servers = ["typescript-language-server" "scls"];
      }) ["typescript" "javascript" "tsx" "jsx"]
      ++ [
        {
          name = "svelte";
          language-servers = ["svelteserver" "scls"];
        }
      ];
  };
}

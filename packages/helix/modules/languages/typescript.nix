{
  flake.nixosModules.whelix-lsp-typescript = {
    lib,
    pkgs,
    ...
  }: {
    languages.language-server = {
      typescript-language-server.command = lib.getExe pkgs.typescript-language-server;
      svelteserver.command = lib.getExe pkgs.svelte-language-server;
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

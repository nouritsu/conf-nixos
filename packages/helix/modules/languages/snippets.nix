{
  flake.nixosModules.whelix-snippets = {
    lib,
    pkgs,
    ...
  }: let
    friendly-snippets = pkgs.vimPlugins.friendly-snippets.src;

    # helix language-id -> friendly-snippets language
    languages =
      lib.genAttrs [
        "c"
        "cpp"
        "css"
        "gdscript"
        "html"
        "javascript"
        "javascriptreact"
        "lua"
        "markdown"
        "nix"
        "python"
        "rust"
        "scss"
        "svelte"
        "typescript"
        "typescriptreact"
        "yaml"
      ]
      lib.id
      // {
        bash = "shellscript";
        git-commit = "gitcommit";
      };

    # scls takes the scope from the file name
    snippets = pkgs.runCommand "helix-snippets" {nativeBuildInputs = [pkgs.jq];} ''
      mkdir $out
      cd ${friendly-snippets}
      ${lib.concatLines (lib.mapAttrsToList (id: language: ''
          jq -s add $(jq -r --arg l ${language} '.contributes.snippets[] | select(.language | if type == "array" then index($l) else . == $l end) | .path' package.json) > $out/${id}.json
        '')
        languages)}
    '';
  in {
    languages.language-server.scls = {
      command = lib.getExe pkgs.simple-completion-language-server;
      environment.SNIPPETS_PATH = "${snippets}";
    };
  };
}

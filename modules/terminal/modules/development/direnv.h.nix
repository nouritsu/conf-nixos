{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  programs.fish.interactiveShellInit =
    /*
    fish
    */
    ''
      direnv hook fish | source
    '';

  programs.fish.shellAbbrs = {
    "direnv-init" = "echo 'use flake' > .envrc && direnv allow";
  };
}

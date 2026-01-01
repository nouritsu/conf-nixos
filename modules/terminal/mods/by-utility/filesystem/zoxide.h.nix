{...}: {
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  home.shellAliases = {
    cd = "z";
  };
}

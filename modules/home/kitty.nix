{lib, ...}: {
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    extraConfig =
      lib.strings.concatStringsSep "\n" [
      ];
  };
}

{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    # Regular
    monaspace
    maple-mono

    # Nerd
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}

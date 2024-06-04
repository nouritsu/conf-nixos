{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    # Regular
    monaspace
    maple-mono
    dejavu_fonts

    # Nerd
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}

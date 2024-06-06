{ pkgs, ... }: {
  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
  stylix.polarity = "dark";
}

{pkgs, ...}: {
  stylix = {
    enable = true;
    image = ../../wallpapers/nix-black-4k.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };
}

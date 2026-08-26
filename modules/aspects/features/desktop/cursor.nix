{
  den.aspects.aneesh.homeManager = {
    lib,
    pkgs,
    ...
  }: let
    catppuccin-mocha-dark-cursors = pkgs.stdenvNoCC.mkDerivation {
      pname = "catppuccin-mocha-dark-cursors";
      version = "2.0.0";
      src = pkgs.fetchzip {
        url = "https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-mocha-dark-cursors.zip";
        hash = "sha256-R11v0XU5IPeIJ7Sy4xSomcgWFvGWsDTeejeJq/GPRmc=";
        stripRoot = false;
      };
      installPhase = ''
        mkdir -p $out/share/icons
        cp -r catppuccin-mocha-dark-cursors $out/share/icons/
      '';
      meta.description = "Catppuccin Mocha Dark cursor theme (prebuilt)";
    };
  in {
    home.pointerCursor = lib.mkForce {
      name = "catppuccin-mocha-dark-cursors";
      package = catppuccin-mocha-dark-cursors;
      size = 24;
      gtk.enable = true;
      hyprcursor = {
        enable = true;
        size = 24;
      };
    };
  };
}

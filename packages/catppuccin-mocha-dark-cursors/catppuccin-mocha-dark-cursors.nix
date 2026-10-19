{
  perSystem = {pkgs, ...}: {
    packages.catppuccin-mocha-dark-cursors = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "catppuccin-mocha-dark-cursors";
      version = "2.0.0";
      src = pkgs.fetchzip {
        url = "https://github.com/catppuccin/cursors/releases/download/v${version}/catppuccin-mocha-dark-cursors.zip";
        hash = "sha256-R11v0XU5IPeIJ7Sy4xSomcgWFvGWsDTeejeJq/GPRmc=";
        stripRoot = false;
      };
      installPhase = ''
        mkdir -p $out/share/icons
        cp -r catppuccin-mocha-dark-cursors $out/share/icons/
      '';
      passthru.nup = [];
      meta.description = "Catppuccin Mocha Dark cursor theme (prebuilt)";
    };
  };
}

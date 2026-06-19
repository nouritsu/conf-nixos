{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    packages.spotify = inputs.spicetify-nix.lib.mkSpicetify pkgs {
      enable = true;

      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
        fullAppDisplay
      ];
    };
  };
}

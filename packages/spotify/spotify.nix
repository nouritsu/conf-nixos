{inputs, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    spicePkgs = inputs'.spicetify-nix.legacyPackages;
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

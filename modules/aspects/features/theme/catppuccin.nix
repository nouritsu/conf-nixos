{inputs, ...}: {
  den.aspects.catppuccin.nixos = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.catppuccin.nixosModules.catppuccin];

    # what DMS picks icons and cursor from
    environment.systemPackages = [
      (pkgs.catppuccin-papirus-folders.override {
        inherit (config.catppuccin) flavor accent;
      })
      pkgs.catppuccin-cursors.mochaDark
    ];

    catppuccin = {
      enable = true;
      # upstream is splitting enable/autoEnable; set both
      autoEnable = true;
      cache.enable = true;
      flavor = "mocha";
      accent = "mauve";

      gtk.icon.enable = true;
      grub.enable = true;
    };

    # glow and other glamour tuis
    environment.sessionVariables.GLAMOUR_STYLE = "${config.catppuccin.sources.glamour}/catppuccin-${config.catppuccin.flavor}.json";
  };
}
